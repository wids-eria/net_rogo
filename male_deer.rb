require File.dirname(__FILE__) + '/deer'
require File.dirname(__FILE__) + '/female_deer'
require 'pry'

class MaleDeer < Deer
#TODO: set active_hours and movement_rates according to time of year or reproductive phase

  MIN_REPRODUCTIVE_ENERGY = 10
  attr_accessor :min_male_reproductive_energy

  def move
    t = 0
    while t < self.active_hours
      if rut?
        t = t + 1
        reproduction_target = select_best_reproduction_patch 
        if reproduction_target[:female_count] > 0      # if females around
          self.location = reproduction_target[:patch].location
          if reproduction_target[:male_count] > 0      # if males around
            local_male_deer = agents_in_radius_of_type(0.02, MaleDeer) # iffy, but more selective than self.patch.agents ALSO #TODO Not sure if I can select male_deer
            jousting_partner = local_male_deer.max_by(&:energy)
            if self.energy > jousting_partner.energy # this is the fight right here
              if self.energy > MIN_REPRODUCTIVE_ENERGY
                attempt_to_mate
              else
                eat
              end
            else
              eat
            end
          else
            if self.energy > MIN_REPRODUCTIVE_ENERGY
              attempt_to_mate
            else
              eat
            end
          end
        else
          local_females = agents_in_radius_of_type(2, FemaleDeer)
          local_females = local_females.select(&:estrus?)
          if local_females.count > 0
            local_females.shuffle.max_by(&:energy) # move towards one of females (preferably receptive ones)
            self.location = [local_females[0].x, local_females[0].y]
          else
            move_to_forage_patch
            eat
          end
        end
      elsif spring_summer?
        move_to_forage_patch
        eat
        t = t + 1
      else # fall by default
        move_to_forage_patch
        eat
        t = t + 1
      # else
      #   raise ArgumentError, 'Current day of year is outside defined season ranges for deer (movement)'
      end
    end
    evaluate_neighborhood_for_bedding(neighborhood_in_radius(1))
    move_to_cover
  end


  def select_best_reproduction_patch
    neighborhood = world.patches_in_radius(self.x, self.y, 1) 
    # identify location with highest fertile female : male ratio
    # for each patch, count number of receptive females and number of males
    count_data = find_male_female_counts(neighborhood)
    count_data.shuffle.sort_by do |patch| 
      if patch[:female_count] == 0 # if there are no females
       move_to_forage_patch 
      else
        patch[:male_count].to_f / patch[:female_count].to_f
      end
    end
    count_data[0]
  end


  def find_male_female_counts(neighborhood)
    neighborhood_data = []
    neighborhood.each do |patch| 
      female_count = 0
      male_count = 0
      # count receptive females on patch
      patch.agents.each do |agent|
        if agent.kind_of? FemaleDeer
          female_count += 1
        elsif agent.kind_of? MaleDeer
          male_count += 1
        end
      end
      neighborhood_data << {patch: patch, male_count: male_count, female_count: female_count}
    end
    neighborhood_data
  end

  def attempt_to_mate
    potential_females = self.patch.agents.select{|agent| agent.kind_of?(FemaleDeer) && agent.estrus?}
    return if potential_females.empty?

    the_one = potential_females.shuffle.max_by(&:energy)
    the_one.impregnate if succesfully_mated?
  end

  def succesfully_mated?
    rand < 0.8
  end
end
