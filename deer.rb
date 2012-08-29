require File.dirname(__FILE__) + '/agent'
#require 'logger'

$log = Logger.new("deer_events.log")

class Deer < Agent

  MAX_ENERGY = 100

 # NEED TO ADD PERSISTENT VARIABLES:
  attr_accessor :age, :energy, :previous_location, :heading, :spawned, :max_energy, :color
  attr_accessor :random_walk_suitable_count, :random_walk_unsuitable_count
  attr_accessor :suitable_neighborhood_selection_count, :backtrack_count

def initialize
    self.spawned = false
    self.energy = 0
    self.age = 0
    self.location = [0.0, 0.0]
    self.heading = 0.0
    self.max_energy = MAX_ENERGY

    self.color = Color::HSL.new(rand * 360, 100, 30)
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

    deer = self.new
    deer.location = [x,y]
    deer.previous_location = [x,y]

    deer.world = world
    world.deers << deer

    deer.energy = deer.max_energy
    deer.spawned = true
    deer
  end

  def spawned?
    spawned.nil? || !spawned
  end

  HABITAT_ATTRIBUTES = { open_water:                  {suitability: -1, forest_type_index: 0},
                         developed_open_space:        {suitability: 1,  forest_type_index: 0},
                         developed_low_intensity:     {suitability: 1,  forest_type_index: 0},
                         developed_medium_intensity:  {suitability: 0,  forest_type_index: 0},
                         developed_high_intensity:    {suitability: 0,  forest_type_index: 0},
                         barren:                      {suitability: 0,  forest_type_index: 0},
                         deciduous:                   {suitability: 1,  forest_type_index: 0},
                         coniferous:                  {suitability: 1,  forest_type_index: 1},
                         mixed:                       {suitability: 1,  forest_type_index: 0.5},
                         dwarf_scrub:                 {suitability: 1,  forest_type_index: 0},
                         shrub_scrub:                 {suitability: 1,  forest_type_index: 0},
                         grassland_herbaceous:        {suitability: 1,  forest_type_index: 0},
                         pasture_hay:                 {suitability: 1,  forest_type_index: 0},
                         cultivated_crops:            {suitability: 1,  forest_type_index: 0},
                         forested_wetland:            {suitability: 1,  forest_type_index: 0},
                         emergent_herbaceous_wetland: {suitability: 1,  forest_type_index: 0},
                         excluded:                    {suitability: -1, forest_type_index: 0} }


  def tick
    raise 'spawn me' if spawned?
    go
  end


  def go
    forage
    bed
    mature
    check_birth
    check_death
  end


  def forage 
    if rut?
      eat
    elsif growing_season?
      eat
    elsif winter?
      eat
    else
      raise ArgumentError, 'Current day of year is outside defined season ranges for deer'
    end
  end


  def bed
    if rut?
    elsif growing_season?
    elsif winter?
    else
      raise ArgumentError, 'Current day of year is outside defined season ranges for deer'
    end
  end


  def move
    evaluate_neigborhood
    set_target
    move_to_target
  end


  def eat
    
  end


  def mature
  end


  def check_birth
  end


  def check_death
  end




  def rut?
    (75..196).include? day_of_year
  end
    
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

end
