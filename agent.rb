require File.dirname(__FILE__) + '/patch'
require File.dirname(__FILE__) + '/number'
require File.dirname(__FILE__) + '/world'
require 'chunky_png'
require 'color'
require 'csv'
require 'logger'


class Agent

  # NEED TO ADD PERSISTENT VARIABLES:
  #attr_accessor :x, :y
  attr_accessor :world

  def initialize
    @x = nil
    @y = nil
  end
  
  def x=(new_x)
    if @x and new_x.to_i != @x.to_i
      if @x != nil && @y != nil 
        patch.remove_agent self
      end
    end
    @x = new_x
    if @x and @y
      patch.add_agent self
    end
  end
  
  def x
    @x
  end
  
  def y=(new_y)
    if @y and new_y.to_i != @y.to_i
      if @x != nil && @y != nil 
        patch.remove_agent self
      end
    end
    @y = new_y
    if @x and @y
      patch.add_agent self
    end
  end
  
  def y
    @y
  end
  
  def id
    object_id
  end


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


  def individuals_in_radius?
    # TODO: finish this function
    puts 'DEFINE INDIVIDUALS IN RADIUS FUNCTION'
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

  def growing_season?
    growing_season_range.include? day_of_year
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
  
  def agents_in_radius(radius)
    patches_in_radius = #
    unflattened_list_of_agents = patches_in_radius.map(do |patch| patch.agents end)
    unflattened_list_of_agents.flatten
  end
  
  def agents_in_radius_of_type(radius, type)
    keepers = []
    agents_in_radius(radius).each do |agent|
      keepers << agent if agent.class.to_s.to_sym == type
    end
    keepers
  end  
end

