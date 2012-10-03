require File.dirname(__FILE__) + '/deer'

attr_accessor :in_euterus, :in_met_diestrus, :in_gestation, :in_lactation, :in_anestrus
#TODO: set active_hours and movement_rates according to time of year or reproductive phase

class FemaleDeer < Deer

  def move
    t = 0
    while t < self.active_hours
      if in_estrus?
        if agents_in_radius_of_type(1, male_deer)
          set in_met_diesrus = True
          t = t + 1
        else
          move
          eat
          t = t + (1 / movement_rate)
        end
      elsif in_met_diesrus?
        eat
        t = t + (1 / movement_rate)
      elsif in_gestation?
        # avoid others
        # extra energy expendature
        eat
        t = t + (1 / movement_rate)
      elsif in_lactation?
        # extra energy expendature
        eat
        t = t + (1 / movement_rate)
      elsif in_anestrus?
        #normal behavior
        eat
        t = t + (1 / movement_rate)
      else
        raise ArgumentError, 'Current day of year is outside defined season ranges for deer (movement)'
      end
    end
    self.age += 1
  end


  def check_birth
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

  def in_estrus?
  end

  def in_met_diesrus?
    (1..).include? self.pregnancy_clock
  end

  def in_gestation?
    (1..).include? self.pregnancy_clock
  end
  
  def in_lactation?
  end

  def in_anestrus?
    
  end

end
