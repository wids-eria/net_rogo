require File.dirname(__FILE__) + '/deer'

class MaleDeer < Deer
#TODO: set active_hours and movement_rates according to time of year or reproductive phase

  def move 
    set_active_hours
    t = 0
    while t < self.active_hours
      if rut?
        if individuals_in_radius?
        # if there are females right here
          # if energy is not too low
            # attempt to copulate
              # if there are males to compete with
                # male with greater energy wins rights, other moves on
                # if won, attempt to mate
                # if female receptive, female becomes pregnant
            # t = t + 1
          # elsif there are females within range
            # move towards females
            # eat
            # t = t + (1 / rut_movement_rate)
        else
          move
          eat
          t = t + (1 / rut_movement_rate)
        end
      elsif spring_summer?
        eat
        t = t + 1
      else
        eat
      # else
      #   raise ArgumentError, 'Current day of year is outside defined season ranges for deer (movement)'
        t = t + 1
      end
    end
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
