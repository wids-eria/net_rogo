require File.dirname(__FILE__) + '/deer'


class MaleDeer < Deer
#TODO: set active_hours and movement_rates according to time of year or reproductive phase

  MIN_REPRODUCTIVE_ENERGY = 10
  attr_accessor :min_male_reproductive_energy

  def move
    t = 0
    while t < self.active_hours
      if rut?
        if agents_in_radius_of_type(1, 'female_deer')        # if females around
          t = t + 1
          if agents_in_radius_of_type(1, 'male_deer')
            # compete
          else
            if self.energy > MIN_REPRODUCTIVE_ENERGY
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

  def active_hours
    if growing_season?
      12
    else
      8
    end
  end
end
