require File.dirname(__FILE__) + '/patch'
require File.dirname(__FILE__) + '/number'
require File.dirname(__FILE__) + '/world'

class Marten

  MAX_ENERGY = 3334.8
  BASE_PATCH_ENTRANCE_PROBABILITY = 0.03
  MAX_VIEW_DISTANCE = 10 
  # approximate max energy (Kj) storage in reserves
  # body fat contains 39.7 kj/g - Buskirk and Harlow 1989
  # body composition mean 5.6% fat - Buskirk and Harlow 1989
  # assume maximum body weight of 1500 g, approximated from Gilbert et al 2009
  # 1500 * 0.056 * 39.7 = 3334.8 kj max energy reserves  # territory_size
  # energy = max_energy # TODO: only during initialization

  # NEED TO ADD PERSISTENT VARIABLES:
  attr_accessor :x, :y
  attr_accessor :world
  attr_accessor :age, :energy, :previous_location, :heading, :spawned

  def id
    object_id
  end

  def initialize
    self.spawned = false
    self.energy = 0
    self.age = 0
    self.location = [0.0, 0.0]
    self.heading = 0.0
  end


  def self.spawn_population(world, count = 100)
    patches_for_spawning = world.all_patches.select{|patch| can_spawn_on? patch}
    raise 'wat' if patches_for_spawning.empty?
    count.times.collect do
      patch = patches_for_spawning.sample
      spawn_at world, patch.center_x, patch.center_y
    end
  end

  def self.spawn_at(world,x,y)

    marten = self.new
    marten.location = [x,y]
    marten.previous_location = [x,y]

    marten.world = world
    world.martens << marten

    marten.energy = MAX_ENERGY
    marten.spawned = true
    marten
  end

  def spawned?
    spawned.nil? || !spawned
  end

  HABITAT_SUITABILITY = { open_water: 0,
                          developed_open_space: 0,
                          developed_low_intensity: 0,
                          developed_medium_intensity: 0,
                          developed_high_intensity: 0,
                          barren: 0,
                          deciduous: 1,
                          coniferous: 1,
                          mixed: 1,
                          dwarf_scrub: 0,
                          shrub_scrub: 0,
                          grassland_herbaceous: 0,
                          pasture_hay: 0,
                          cultivated_crops: 0,
                          forested_wetland: 1,
                          emergent_herbaceous_wetland: 0,
                          excluded: 0 }


  def day_of_year
    world.day_of_year
  end


  def turn(degrees)
    self.heading += degrees
    self.heading %= 360
  end


  def face_patch(patch)
    face_location [patch.center_x, patch.center_y]
  end

  def face_location(coordinates)
    delta_x = coordinates[0] - self.x
    delta_y = coordinates[1] - self.y
    self.heading = Math::atan2(delta_y, delta_x).in_degrees % 360
  end


  def patch_ahead(distance)
    patch_x = Math::cos(heading.in_radians) * distance + x
    patch_y = Math::sin(heading.in_radians) * distance + y
    world.patch patch_x, patch_y
  end


  def neighborhood_in_radius radius = 0
    world.patches_in_radius(x, y, radius) - [self.patch]
  end

  def neighborhood
    x = self.x.floor
    y = self.y.floor
    [ world.patch(x-1,y-1),
      world.patch(x-1,y),
      world.patch(x-1,y+1),
      world.patch(x,y-1),
      world.patch(x,y+1),
      world.patch(x+1,y-1),
      world.patch(x+1,y),
      world.patch(x+1,y+1) ].compact
  end

  # psst, 'netlogo' neighborhood.. patch center x/y

  def self.habitat_suitability_for(patch)
    HABITAT_SUITABILITY[patch.land_cover_class]
  end

  def habitat_suitability_for(patch)
    self.class.habitat_suitability_for patch
  end

  def self.passable?(patch)
    !patch.nil?
  end

  def passable?(patch)
    self.class.passable? patch
  end

  

  def walk_forward(distance)
    raise 'no previous location' if previous_location.nil?
    self.x = Math::cos(heading.in_radians) * distance + x
    self.y = Math::sin(heading.in_radians) * distance + y
  end


  def growing_season_range
    80..355
  end

  def growing_season?
    growing_season_range.include? day_of_year
  end

  def active_hours
    if growing_season?
      12
    else
      8
    end
  end

  def forage
    active_hours.times do
      hourly_routine
    end
  end


  def location
    [self.x, self.y]
  end

  def location=(coordinates)
    self.x = coordinates[0]
    self.y = coordinates[1]
  end

  def patch
    world.patch(self.x, self.y)
  end

  def satiated?
    energy >= (MAX_ENERGY * 1.5)
  end


  def hourly_routine
    actual_dist = 0
    while actual_dist < forage_distance
      actual_dist += 1

      if satiated?
        # TODO test me
        self.energy = MAX_ENERGY
        break
      end

      do_stuff
    end
  end

  def do_stuff
    face_random_direction
    move_one_patch
    leave_scent_mark
    hunt
    check_predation
    remember_previous_location
  end


  def forage_distance
    1000 / 63.62
  end


  def select_forage_patch_and_move
    patches = desireable_patches
    if patches.empty?
      unless self.previous_location == location
        face_location self.previous_location # FIXME centroid of patch? or exact location?
        walk_forward 1
      end
    else
      face_patch patches.shuffle.max_by(&:max_vole_pop)
      walk_forward 1
    end
  end


  def hunt
    # assumes 1.52712 encounters per step - equivalent to uncut forest encounter rate from Andruskiw et al 2008
    # probability of kill in uncut forest 0.05 (calculated from Andruskiw's values; 0.8 kills/24 encounters)
    # probability of kill in 1 step = 1.52712 * 0.05 = 0.076356
    # modify p_kill based on vole population
#            begin
    p_kill = 0.076356
    tile_here = self.patch

    if tile_here.vole_population < 1
      p_kill = 0
    else
      # discount p_kill based on proportion of vole capacity in patch
      p_kill = (p_kill * (tile_here.vole_population / tile_here.max_vole_pop))
    end

    if rand > (1 - p_kill)
      self.energy += 140
      tile_here.vole_population -= 1
    end
  end


  def check_predation
    if habitat_suitability_for(self.patch) == 1
      p_mort = Math.exp(Math.log(0.99897) / self.active_hours) # based on daily predation rates decomposed to hourly rates (from Thompson and Colgan (1994))
    else
      p_mort = Math.exp(Math.log(0.99555) / self.active_hours)
    end

    if rand > p_mort
      print '!'
      die
    end
  end


  def metabolize
    if growing_season?
      self.energy -= 857 # field metabolic rate (above)
    else
      self.energy -= 227
    end

    if energy > MAX_ENERGY
      energy = MAX_ENERGY
    end
  end


  def die_if_starved
    if energy < 0
      print ':('
      die
    end
  end


  def die
    world.martens.delete self
  end


  def remember_previous_location
    self.previous_location = location
  end
end
