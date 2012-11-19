require 'set'
require File.dirname(__FILE__) + '/db_connector'
require File.dirname(__FILE__) + '/db_models/resource_tile'

class Patch
  require File.dirname(__FILE__) + '/deer_landscape_functions'
  include DeerLandscapeFunctions
  
  attr_accessor :x, :y
  attr_accessor :marten, :marten_scent_age
  attr_accessor :land_cover_class
  attr_accessor :site_index

  attr_accessor :max_vole_pop
  attr_accessor :vole_population
  attr_accessor :deer_browse
  attr_accessor :deer_fall_winter_food, :deer_spring_summer_food, :deer_thermal_cover
  
  include DatabaseSync
  sync_fields :x, :y, :vole_population

  MAX_VOLE_POP = 13.9
  UNHINDERED_VOLE_GROWTH_RATE = 0.00344

  LAND_COVER_CLASSES = { 11 => :open_water,
                         21 => :developed_open_space,
                         22 => :developed_low_intensity,
                         23 => :developed_medium_intensity,
                         24 => :developed_high_intensity,
                         31 => :barren,
                         41 => :deciduous,
                         42 => :coniferous,
                         43 => :mixed,
                         51 => :dwarf_scrub,
                         52 => :shrub_scrub,
                         71 => :grassland_herbaceous,
                         81 => :pasture_hay,
                         82 => :cultivated_crops,
                         90 => :forested_wetland,
                         95 => :emergent_herbaceous_wetland,
                        255 => :excluded }

  COLORS = { :deciduous        => [ 93, 169, 109],
             :cultivated_crops => [184, 110,  52],
             :forested_wetland => [180, 216, 235],
             :mixed            => [188, 203, 152],
             :coniferous       => [  0, 102,  56],
             :developed_open_space => [229, 204, 206],
             :emergent_herbaceous_wetland => [ 96, 166, 191],
             :pasture_hay => [225, 214, 88],
             :developed_low_intensity => [231, 148, 131],
             :open_water => [ 56, 112, 159],
             :developed_high_intensity => [186,  0,  5],
             :barren => [180, 175, 165],
             :developed_medium_intensity => [255,  0,  8],
             :grassland_herbaceous => [238, 235, 208],
             :shrub_scrub => [214, 185, 136],
             :excluded => [0, 0, 0]}


  def initialize(resource_tile = nil)
    self.max_vole_pop = MAX_VOLE_POP
    self.deer_fall_winter_food = 0
    self.deer_spring_summer_food = 0
    self.deer_thermal_cover = 0
    self.site_index = 80

    @agents = Set.new

    if resource_tile
      use_correspondent resource_tile
      self.vole_population ||= self.max_vole_pop 
      self.land_cover_class = resource_tile.land_cover_type
    else
      self.land_cover_class = :barren
      self.vole_population = self.max_vole_pop
    end    
  end

  def add_agent(agent)
    @agents<<agent unless agents.member? agent
  end
  
  def remove_agent(agent)
    @agents.delete agent
  end
  
  def agents
    @agents.to_a
  end
  
  def tick
    age_and_expire_scents
    grow_voles
    calculate_deer_metrics
  end

  def location
    [self.x,self.y]
  end

  def center_x
    self.x + 0.5
  end

  def center_y
    self.y + 0.5
  end

  def age_and_expire_scents
    return if self.marten_scent_age.nil?
    self.marten_scent_age += 1
    if marten_scent_age >= 14
      self.marten_scent_age = nil
      self.marten = nil
    end
  end

  def grow_voles
    density_dependent_growth_delta = daily_growth_delta * (1 - (self.vole_population/self.max_vole_pop))
    self.vole_population = self.vole_population + density_dependent_growth_delta * self.vole_population
  end

  def daily_growth_delta
    UNHINDERED_VOLE_GROWTH_RATE
  end

  def calculate_deer_food_base
    # TODO: use indexes to determine potential, and logistic growth - deer removal to indicate current food amounts
  end

  def calculate_deer_metrics
    # TODO: these indices only needs to be updated once per year
    self.deer_thermal_cover = self.assess_thermal_cover
    self.deer_spring_summer_food = self.assess_spring_summer_food_potential
    self.deer_fall_winter_food = self.assess_fall_winter_food_potential
  end

  def land_cover_from_code(code)
    self.land_cover_class = LAND_COVER_CLASSES[code] || raise("unknown code #{code}")
  end

  def color
    COLORS[self.land_cover_class] || raise("#{self.land_cover_class} needs color")
  end
end
