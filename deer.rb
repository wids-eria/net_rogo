require File.dirname(__FILE__) + '/agent'
require File.dirname(__FILE__) + '/deer_landscape_functions'

#require 'logger'

$log = Logger.new("deer_events.log")

class Deer < Agent

  include DeerLandscapeFunctions
  
  MAX_ENERGY = 100

 # NEED TO ADD PERSISTENT VARIABLES:
  attr_accessor :x, :y, :world
  attr_accessor :age, :energy, :previous_location, :heading, :spawned, :max_energy, :color
  attr_accessor :random_walk_suitable_count, :random_walk_unsuitable_count
  attr_accessor :suitable_neighborhood_selection_count, :backtrack_count
  attr_accessor :movement_rate

def initialize
  super
  self.spawned = false
  self.energy = 0
  self.age = 0
  self.location = [0.0, 0.0]
  self.heading = 0.0
  self.max_energy = MAX_ENERGY

  self.color = Color::HSL.new(rand * 360, 100, 30)
 end

  def self.spawn_population(world, count = 10)
    patches_for_spawning = world.all_patches.select{|patch| can_spawn_on? patch}
    raise 'wat' if patches_for_spawning.empty?
    count.times.collect do
      patch = patches_for_spawning.sample
      spawn_at world, patch.center_x, patch.center_y
    end
  end

  def self.spawn_at(world,x,y)

    deer = self.new
    deer.location = [x,y]


    deer.world = world
    world.deers << deer

    deer.energy = deer.max_energy
    deer.spawned = true
    deer
  end

  def spawned?
    spawned.nil? || !spawned
  end

  HABITAT_ATTRIBUTES = { open_water:                  {suitability: -1, forest_type_index: 0, visibility: 0, forest: 0},
                         developed_open_space:        {suitability: 1,  forest_type_index: 0, visibility: 2, forest: 0},
                         developed_low_intensity:     {suitability: 1,  forest_type_index: 0, visibility: 1, forest: 0},
                         developed_medium_intensity:  {suitability: 0,  forest_type_index: 0, visibility: 1, forest: 0},
                         developed_high_intensity:    {suitability: 0,  forest_type_index: 0, visibility: 1, forest: 0},
                         barren:                      {suitability: 0,  forest_type_index: 0, visibility: 2, forest: 0},
                         deciduous:                   {suitability: 1,  forest_type_index: 0, visibility: 1, forest: 1},
                         coniferous:                  {suitability: 1,  forest_type_index: 1, visibility: 1, forest: 1},
                         mixed:                       {suitability: 1,  forest_type_index: 0.5, visibility: 1, forest: 1},
                         dwarf_scrub:                 {suitability: 1,  forest_type_index: 0, visibility: 2, forest: 0},
                         shrub_scrub:                 {suitability: 1,  forest_type_index: 0, visibility: 2, forest: 0},
                         grassland_herbaceous:        {suitability: 1,  forest_type_index: 0, visibility: 2, forest: 0},
                         pasture_hay:                 {suitability: 1,  forest_type_index: 0, visibility: 2, forest: 0},
                         cultivated_crops:            {suitability: 1,  forest_type_index: 0, visibility: 1, forest: 0},
                         forested_wetland:            {suitability: 1,  forest_type_index: 0, visibility: 1, forest: 1},
                         emergent_herbaceous_wetland: {suitability: 1,  forest_type_index: 0, visibility: 2, forest: 0},
                         excluded:                    {suitability: -1, forest_type_index: 0, visibility: 0, forest: 0}}


  def tick
    raise 'spawn me' if spawned?
    go
  end


  def go
    set_movement_rate
    # puts world.day_of_year
    move
    bed
    mature
    # check_birth
    check_death
  end

  def set_movement_rate
   self.movement_rate = 6
   #if rut?
   #  movement_rate = 6.5
   #elsif spring_summer?

   #else
   #  # Default to fall_winter
   #  movement_rate = 6
   #  #  raise Error, 'Current day of year is outside defined season ranges for deer (calculating movement rate)'
   #end
  end





  def bed
    if rut?
    elsif spring_summer?
    else
      # Default to fall_winter behavior
      # raise ArgumentError, 'Current day of year is outside defined season ranges for deer (bedding)'
    end
  end


  def evaluate_neighborhood_for_forage
    if spring_summer?
      assess_spring_summer_food_potential
    else
      assess_fall_winter_food_potential
    end
  end


  def move_to_cover
    # evaluate_steps; permits longer term decision analysis
  end


  def evaluate_neighborhood_for_bedding
  end


  def eat
    
  end


  def mature
  end


  def check_death
  end




  def rut?
    # Approximating from random website
    (268..309).include? world.day_of_year
  end

  def spring_summer?
    (79..264).include? world.day_of_year
  end

  # def fall_winter?
  #   if (265..267).include? world.day_of_year || (310..365).include? world.day_of_year || (0..78).include? world.day_of_year
  # end
    
  def self.habitat_suitability_for(patch)
    HABITAT_ATTRIBUTES[patch.land_cover_class][:suitability]
  end

  def habitat_suitability_for(patch)
    self.class.habitat_suitability_for patch
  end

  def self.can_spawn_on?(patch)
    self.passable?(patch) && self.habitat_suitability_for(patch) == 1
  end
 
  def self.passable?(patch)
    !patch.nil? && habitat_suitability_for(patch) != -1 
  end

  def passable?(patch)
    self.class.passable? patch
  end


  def evaluate_steps
    immediate_neighborhood = neigborhood_in_radius 1
    first_order_steps = immediate_neighborhood.collect
    HABITAT_ATTRIBUTES[patch.land_cover_class][:suitability]
    HABITAT_ATTRIBUTES[patch.land_cover_class][:visibility]
  end

  def execute_move_sequence
  end

  def die_from_mortality_trial?
    rand > mortality_probability
  end

  def mortality_probability
    if self.patch.land_cover_class == :developed_low_intensity 
      (rand 0.20 + 0.62) ^ (1 / 365)
    else
     (rand 0.19 + 0.57) ^ (1 / 365) 
    end
  end

end
