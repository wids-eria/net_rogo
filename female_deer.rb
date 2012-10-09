require File.dirname(__FILE__) + '/deer'

class FemaleDeer < Deer

attr_accessor :reproductive_stage, :reproductive_clock, :estrous_clock, :estrous_cycle_length
#TODO: set active_hours and movement_rates according to time of year or reproductive phase

  def initialize
    super
    self.reproductive_clock = 0
    self.reproductive_stage = :anestrous
    self.estrous_cycle_length = rand(2) + 3
  end

  def move
    forage
    tick_reproductive_clock
    check_death
    self.age += 1
    self.energy -= 1
  end


  def forage
  
  end


  def tick_reproductive_clock
    if impregnated?
      self.reproductive_clock += 1
    end
  end
 

  def impregnate
    self.reproductive_clock = 0
    self.reproductive_stage = :impregnated
  end


  def tick_reproductive_clock

    if self.reproductive_stage == :impregnated
      self.reproductive_clock += 1
    end

    if (5..200).include? self.reproductive_clock
      self.reproductive_stage = :gestation
      self.reproductive_clock += 1
    end

    if self.reproductive_clock == 201
        self.reproductive_stage = :parturition
        give_birth
        self.reproductive_clock += 1
    end

    if (201..260).include? self.reproductive_clock
      self.reproductive_stage = :lactation
      self.reproductive_clock += 1
    end

    if self.reproductive_clock > 260
      self.reproductive_stage = :anestrous
      self.reproductive_clock += 1
    end
    
    # Rut behavior
    if rut? and (age > 365)
      if self.reproductive_stage == :anestrous
        self.estrous_clock = rand(estrous_cycle_length) + 1
        self.reproductive_stage = :di_metestrus
      end

      if self.reproductive_stage == :di_metestrus
        self.estrous_clock += 1
        if self.estrous_clock > self.estrous_cycle_length 
          self.reproductive_stage = :in_estrous
          self.estrous_clock = 0
        end
      end

      if self.reproductive_stage == :in_estrous
        self.estrous_clock += 1
        if self.estrous_clock > self.estrous_cycle_length 
          self.reproductive_stage = :di_metestrus
          self.estrous_clock = 0
        end
      end
    end
  end


  def give_birth
    (rand(2) + 1).times.each do
      if rand > 0.5
        FemaleDeer.spawn_at(self.world, self.x, self.y)
      else 
        MaleDeer.spawn_at(self.world, self.x, self.y)
      end
    end
  end


  def forage
    t = 0
    while t < self.active_hours 
      if rut?
        evaluate_neighborhood_for_forage
        eat
        t = t + 1
      elsif spring_summer?
        evaluate_neighborhood_for_forage
        eat
        t = t + 1
      else # fall by default
        evaluate_neighborhood_for_forage
        eat
        t = t + 1
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


    
end



