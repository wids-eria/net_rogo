require File.dirname(__FILE__) + '/patch'
require File.dirname(__FILE__) + '/number'
require File.dirname(__FILE__) + '/world'
require 'chunky_png'
require 'color'
require 'csv'
require 'logger'

$log = Logger.new("marten_events.log")

class Marten

  MAX_ENERGY = 3334.8
  BASE_PATCH_ENTRANCE_PROBABILITY = 0.03
  # approximate max energy (Kj) storage in reserves
  # body fat contains 39.7 kj/g - Buskirk and Harlow 1989
  # body composition mean 5.6% fat - Buskirk and Harlow 1989
  # assume maximum body weight of 1500 g, approximated from Gilbert et al 2009
  # 1500 * 0.056 * 39.7 = 3334.8 kj max energy reserves  # territory_size
  # energy = max_energy # TODO: only during initialization

  # NEED TO ADD PERSISTENT VARIABLES:
  attr_accessor :x, :y
  attr_accessor :world
  attr_accessor :age, :energy, :previous_location, :heading, :spawned, :max_energy, :color
  attr_accessor :random_walk_suitable_count, :random_walk_unsuitable_count
  attr_accessor :suitable_neighborhood_selection_count, :backtrack_count

  def id
    object_id
  end

  def initialize
    self.spawned = false
    self.energy = 0
    self.age = 0
    self.location = [0.0, 0.0]
    self.heading = 0.0
    self.max_energy = MAX_ENERGY

    self.color = Color::HSL.new(rand * 360, 100, 30)


     self.random_walk_suitable_count = 0
     self.random_walk_unsuitable_count = 0
     self.suitable_neighborhood_selection_count = 0
     self.backtrack_count = 0
  end


  def self.spawn_population(world, count = 100)
    patches_for_spawning = world.all_patches.select{|patch| can_spawn_on? patch}
    raise 'no patches available to spawn on' if patches_for_spawning.empty?
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

    marten.energy = marten.max_energy
    marten.spawned = true
    marten
  end

  def spawned?
    spawned.nil? || !spawned
  end

  HABITAT_SUITABILITY = { open_water: -1,
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
                          forested_wetland: 0,
                          emergent_herbaceous_wetland: 0,
                          excluded: -1 }


  def day_of_year
    world.day_of_year
  end

  def stay_probability
    (1 - BASE_PATCH_ENTRANCE_PROBABILITY) * (self.energy / MAX_ENERGY)
  end


  def should_leave?
    stay_probability < rand
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


  def self.habitat_suitability_for(patch)
    HABITAT_SUITABILITY[patch.land_cover_class]
  end

  def habitat_suitability_for(patch)
    self.class.habitat_suitability_for patch
  end

  def self.passable?(patch)
    !patch.nil? && habitat_suitability_for(patch) != -1 
  end

  def passable?(patch)
    self.class.passable? patch
  end


  def move_one_patch
    target = patch_ahead 1

    # faced patch desirable
    # faced patch force move
    #
    # find desirable neighboring patch
    # no desirable, about face

    if passable?(target)
      if patch_desirable?(target)
        walk_forward 1
        self.random_walk_suitable_count += 1
      elsif should_leave?
        walk_forward 1
        self.random_walk_unsuitable_count += 1
      else
        select_forage_patch_and_move
      end
    else
      select_forage_patch_and_move
    end
  end


  def desirable_patches
    #neighborhood_in_radius(1).select{|patch| patch_desirable? patch }
    neighborhood.select{|patch| patch_desirable? patch }
  end


  def self.can_spawn_on?(patch)
    self.passable?(patch) && self.habitat_suitability_for(patch) == 1
  end
  

  def walk_forward(distance)
    raise 'no previous location' if previous_location.nil?
    self.x = Math::cos(heading.in_radians) * distance + x
    self.y = Math::sin(heading.in_radians) * distance + y
  end


  def growing_season_range
    80..355
  end

  def summer?
    (197..319).include? day_of_year
  end

  def winter?
    day_of_year > 319 || day_of_year < 75
  end

  def kit_rearing?
    (75..196).include? day_of_year
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
    self.energy >= (self.max_energy)
  end


  def hourly_routine
    actual_dist = 0
    while actual_dist < forage_distance
      actual_dist += 1

      if satiated?
        # TODO test me
        self.energy = self.max_energy
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
    patches = desirable_patches
    if patches.empty?
      unless self.previous_location == location
        face_location self.previous_location # FIXME centroid of patch? or exact location?
        walk_forward 1
        self.backtrack_count += 1
      end
    else
      face_patch patches.shuffle.max_by(&:max_vole_pop)
      walk_forward 1
      self.suitable_neighborhood_selection_count += 1
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
    if die_from_fatal_blows?
      $log.info "#{self.id} died from predation"
      die
    end
  end

  def die_from_fatal_blows?
    rand > mortality_probability
  end

  def mortality_probability
    datums = {
      "MaleMarten" => {
        summer: [1,0.9965765],
        winter: [0.9992273,0.9958064],
        kit_rearing: [0.9994149,0.9959934]
      },
      "FemaleMarten" => {
        summer: [1,0.9965765],
        winter: [0.99780611,0.9943901],
        kit_rearing: [0.9993278,0.9959066]
      }
    }
    if habitat_suitability_for(self.patch) == 1
      #return Math.exp(Math.log(0.99897) / self.active_hours) # based on daily predation rates decomposed to hourly rates (from Thompson and Colgan (1994))
      #return 0.99897**(1/self.active_hours)
      return datums[self.class.to_s][:summer][0] if summer?
      return datums[self.class.to_s][:winter][0] if winter?
      return datums[self.class.to_s][:kit_rearing][0] if kit_rearing?
      
    else
      #return Math.exp(Math.log(0.99555) / self.active_hours)
      #return 0.99555**(1/self.active_hours)
      return datums[self.class.to_s][:summer][1] if summer?
      return datums[self.class.to_s][:winter][1] if winter?
      return datums[self.class.to_s][:kit_rearing][1] if kit_rearing?
     end
  end


  def stay_probability
    (1 - BASE_PATCH_ENTRANCE_PROBABILITY) * (self.energy / MAX_ENERGY)
  end


  def should_leave?
    stay_probability < rand
  end
  
  def desirable_patches
    #neighborhood_in_radius(1).select{|patch| patch_desirable? patch }
    neighborhood.select{|patch| patch_desirable? patch }
  end

  def metabolize
    if growing_season?
      self.energy -= 857 # field metabolic rate (above)
    else
      self.energy -= 227
    end

    if self.energy > self.max_energy
      self.energy = self.max_energy
    end
  end


  def die_if_starved
    if energy < 0
      $log.info "#{self.id} died from starvation"
      die
    end
  end


  def die
    output_stats

    world.martens.delete self
  end

  def output_stats
    dir_name = File.join(self.world.job_name)
    FileUtils.mkdir_p(dir_name)
    CSV.open(File.join(dir_name, "marten_stats.csv"), "ab") do |csv_file|
      csv_file << [id, random_walk_suitable_count, random_walk_unsuitable_count, suitable_neighborhood_selection_count, backtrack_count, energy, world.tick_count]
    end
  end


  def remember_previous_location
    self.previous_location = location
  end
  
  def move_one_patch
    target = patch_ahead 1

    # faced patch desirable
    # faced patch force move
    #
    # find desirable neighboring patch
    # no desirable, about face

    if passable?(target)
      if patch_desirable?(target)
        walk_forward 1
        self.random_walk_suitable_count += 1
      elsif should_leave?
        walk_forward 1
        self.random_walk_unsuitable_count += 1
      else
        select_forage_patch_and_move
      end
    else
      select_forage_patch_and_move
    end
  end
end
