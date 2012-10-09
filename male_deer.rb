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
            local_male_deer.sort! {|x,y| x.energy <=> y.energy}
            raise 'WE FIGHT!!!!'
            if self.energy > local_male_deer[0].energy
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
          local_females = local_females.select {|female| female.reproductive_stage == :in_estrus}
          if local_females.count > 0
            local_females.shuffle.max_by(&:energy) # move towards one of females (preferably receptive ones)
            puts 'move towards one of females (preferably receptive ones)'
            self.location = [local_females[0].x, local_females[0].y]
          else
          # change location
            evaluate_neighborhood_for_forage
            eat
          end
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


  def select_best_reproduction_patch
    neighborhood = world.patches_in_radius(self.x, self.y, 1) 
    puts "new neighborhood looks like #{neighborhood.count}"
    # identify location with highest fertile female : male ratio
    # for each patch, count number of receptive females and number of males
    count_data = find_male_female_counts(neighborhood)
    count_data.shuffle.sort_by do |patch| 
      if patch[:female_count] == 0 # if there are no females
        0.0
      else
        patch[:male_count].to_f / patch[:female_count].to_f
      end
    end
    puts count_data.collect{|c| [c[:female_count], c[:male_count]]}.inspect
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
    potential_females = self.patch.agents.select{|agent| agent.kind_of?(FemaleDeer) && agent.in_estrus?}
    return if potential_females.empty?

    the_one = potential_females.shuffle.max_by(&:energy)
    the_one.impregnate if succesfully_mated?
  end

  def succesfully_mated?
    rand < 0.8
  end
end
