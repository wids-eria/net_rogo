require File.dirname(__FILE__) + '/deer'


class MaleDeer < Deer
#TODO: set active_hours and movement_rates according to time of year or reproductive phase

  MIN_REPRODUCTIVE_ENERGY = 10
  attr_accessor :min_male_reproductive_energy

  def move
    t = 0
    while t < self.active_hours
      if rut?
        potential_mates = find_potential_mates
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
    evaluate_neighborhood_for_bedding(neighborhood_in_radius(1))
    move_to_cover
    self.age += 1
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

  def find_potential_mates
    neighborhood = world.patches_in_radius(self.x, self.y, 1) 
    puts "new neighborhood looks like #{neighborhood.count}"
    # identify location with highest fertile female : male ratio
    # for each patch, count number of receptive females and number of males
    count_data = find_male_female_counts(neighborhood)
    count_data.sort_by do |patch| 
      if patch[2] == 0
        0
      else
        patch[1] / patch[2]
      end
      puts "selected patch is #{count_data[0]}"
    end

    #puts "mate availability looks like: #{count_data}"
  end


  def find_male_female_counts(neighborhood)
    neighborhood_data = []
    neighborhood.each do |patch| 
      female_count = 0
      male_count = 0
      # count receptive females on patch
      patch.agents.each do |agent|
        if agent.class == :female_deer
          if agent.in_estrus?
            female_count += 1
          end
        elsif agent.class == :male_deer
          male_count += 1
        end
      end
      neighborhood_data << [patch, male_count, female_count]
    end
    neighborhood_data
    # puts "that's it!"
  end
end
