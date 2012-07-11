require File.dirname(__FILE__) + '/patch'
require File.dirname(__FILE__) + '/world'

class Marten

 MAX_ENERGY = 3334.8
  PATCH_ENTRANCE_PROBABILITY = 0.03
  MAX_VIEW_DISTANCE = 10 
  # approximate max energy (Kj) storage in reserves
  # body fat contains 39.7 kj/g - Buskirk and Harlow 1989
  # body composition mean 5.6% fat - Buskirk and Harlow 1989
  # assume maximum body weight of 1500 g, approximated from Gilbert et al 2009
  # 1500 * 0.056 * 39.7 = 3334.8 kj max energy reserves  # territory_size
  # energy = max_energy # TODO: only during initialization

  # NEED TO ADD PERSISTENT VARIABLES:
  attr_accessor :age, :energy, :neighborhood, :previous_location, :target, :heading


  def initialize
    self.energy = 0
    self.age = 0
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
    1
  end


  def turn(degrees)
  end


  def patch_ahead(dist)
    Patch.new
  end


  def nearby_tiles(radius = 0)
    # array?
  end


  def habitat_suitability_for(tiles)
    rand(1)
  end


  def walk_forward(distance)
  end


  def world
    World.new
  end


  def x
    0
  end


  def y
    0
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
  end


  def hourly_routine
    actual_dist = 0
    while actual_dist < forage_distance
      move_one_patch
      hunty_hunt
      check_predation
      set_previous_location
      actual_dist += 1
      if energy > MAX_ENERGY * 1.5
        set energy MAX_ENERGY
        break #TODO: make sure this is doing what I think it's doing
      end
    end
  end


  def forage_distance 
    1000 / 63.62
  end


  def select_forage_patch
    set_neighborhood
    if self.neighborhood.empty?
      self.target = previous_location
    else
      self.target = self.neighborhood.shuffle.max_by(&:max_vole_pop)
    end
    face self.target
  end


  def hunty_hunt
    hunt
  end


  def hunt
    # assumes 1.52712 encounters per step - equivalent to uncut forest encounter rate from Andruskiw et al 2008
    # probability of kill in uncut forest 0.05 (calculated from Andruskiw's values; 0.8 kills/24 encounters)
    # probability of kill in 1 step = 1.52712 * 0.05 = 0.076356
    # modify p_kill based on vole population
#            begin
    p_kill = 0.076356
    tile_here = self.world.resource_tile_at self.x, self.y 
    if tile_here.population[:vole_population] < 1 #TODO need to access "tile_here" data
      p_kill = 0
    else
      # discount p_kill based on proportion of vole capacity in patch
      p_kill = (p_kill * (tile_here.population[:vole_population] / tile_here.max_vole_pop))
    end
    if rand > (1 - p_kill)
      self.energy += 140
      tile_here.population[:vole_population] = (tile_here.population[:vole_population] - 1)
    end
  end


  def check_predation
    if habitat_suitability_for (self.world.resource_tile_at self.x, self.y) == 1 #TODO: double check this arg
      p_mort = Math.exp(Math.log(0.99897) / self.active_hours) # based on daily predation rates decomposed to hourly rates (from Thompson and Colgan (1994))
    else
      p_mort = Math.exp(Math.log(0.99555) / self.active_hours)
    end

    if rand > p_mort
      die #TODO: make sure 'die' works
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
      die
    end
  end


  def set_previous_location
    previous_location = location
  end
end
