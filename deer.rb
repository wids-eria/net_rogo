require File.dirname(__FILE__) + '/agent'
require File.dirname(__FILE__) + '/deer_landscape_functions'

#require 'logger'

$log = Logger.new("deer_events.log")

class Deer < Agent

  include DeerLandscapeFunctions

  MAX_ENERGY = 100
  MAXIMUM_AGE = 5475 # 15 years?

 # NEED TO ADD PERSISTENT VARIABLES:
  attr_accessor :world
  attr_accessor :age, :energy, :previous_location, :heading, :spawned, :max_energy, :color
  attr_accessor :random_walk_suitable_count, :random_walk_unsuitable_count
  attr_accessor :suitable_neighborhood_selection_count, :backtrack_count
  attr_accessor :movement_rate

def initialize
  super
  self.spawned = false
  self.energy = 0
  self.age = 0
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
    deer.world = world

    deer.location = [x,y]
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
    move
    # TODO bed
    mature
    check_death
  end


  def bed
    raise 'define bed'
    if rut?
    elsif spring_summer?
    else
      # Default to fall_winter behavior
      # raise ArgumentError, 'Current day of year is outside defined season ranges for deer (bedding)'
    end
  end

  def move_to_cover
    raise 'calling empty method'
    # evaluate_steps; permits longer term decision analysis
    # target = evaluate_neighborhood_for_bedding(neighborhood_in_radius(1))
    # self.location = [target.x, target.y]
  end

  def evaluate_neighborhood_for_bedding(patchset)
    patchset.sort { |x, y| assess_bedding_potential(x) <=> assess_bedding_potential(y) }
  end


  def evaluate_neighborhood_for_forage
    neighborhood = neighborhood_in_radius(1)
    target = select_highest_score_of_patch_set(neighborhood)
  end

  def move_to_patch_center patch
    self.location = [(patch.x + 0.5), (patch.y + 0.5)]
  end

  def select_highest_score_of_patch_set(patch_set)     if spring_summer?
      patch_set.sort! { |x, y| assess_spring_summer_food_potential(x) <=> assess_spring_summer_food_potential(y) }
    else
      patch_set.sort! { |x, y| assess_fall_winter_food_potential(x) <=> assess_fall_winter_food_potential(y) }
    end
  patch_set[0]
  end


  def eat
    raise 'calling empty method'

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


  def mature
    self.age += 1
  end


  def check_death
    if die_from_mortality_trial? || die_from_old_age?
      world.deers.delete self
    end
  end


  def die_from_mortality_trial?
    rand > mortality_probability
  end


  def die_from_old_age?
    self.age > MAXIMUM_AGE
  end

  
  def mortality_probability
    if self.patch.land_cover_class == :developed_low_intensity
      ((rand * 0.20) + 0.62) ** (1.0 / 365)
    else
     ((rand * 0.19) + 0.57) ** (1.0 / 365)
    end
  end


  def active_hours
    if rut?
      12
    elsif spring_summer?
      8
    else
      6
      # Default to fall_winter behavior
      # raise ArgumentError, 'Current activity level is outside defined season ranges for deer'
    end
  end


  def move_to_forage_patch
    patch = evaluate_neighborhood_for_forage
    move_to_patch_center patch
  end

end
