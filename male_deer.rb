require File.dirname(__FILE__) + '/deer'
require File.dirname(__FILE__) + '/deer_landscape_functions'


class MaleDeer < Deer
#TODO: set active_hours and movement_rates according to time of year or reproductive phase

  include DeerLandscapeFunctions
  
  attr_accessor :min_male_reproductive_energy
  
  def move 
    set_active_hours
    t = 0
    while t < self.active_hours
      if rut?
        if agents_in_radius_of_type(1, female_deer)        # if females around
          t = t + 1
          if agents_in_radius_of_type(1, male_deer)
            # compete
          else
            if self.energy > min_male_reproductive_energy
              # try to get lady preggers
            else
              eat
            end
          end
        elsif agents_in_radius_of_type(2, female_deer)
          # move towards one of females (preferably receptive ones)
          # t = t + (1 / rut_movement_rate)
        else
          # change location
          evaluate_neighborhood_for_forage
          eat
          t = t + 1 
        end
      elsif spring_summer?
        evaluate_neighborhood_for_forage
        eat
        t = t + 1
      else # fall by default 
        evaluate_neighborhood_for_forage
        eat
        t = t + 1
      # else
      #   raise ArgumentError, 'Current day of year is outside defined season ranges for deer (movement)'
      end
    end
    evaluate_neighborhood_for_bedding
    move_to_cover
  end

  def set_active_hours
    if rut? 
      self.active_hours = 12
    elsif spring_summer?
      self.active_hours = 8
    else
      self.active_hours = 6
      # Default to fall_winter behavior
      # raise ArgumentError, 'Current activity level is outside defined season ranges for deer'
    end
  end

end
