require File.dirname(__FILE__) + '/deer'
require File.dirname(__FILE__) + '/male_deer'
require File.dirname(__FILE__) + '/deer_reproductive_stages'

class FemaleDeer < Deer
  include DeerReproductiveStages

  attr_accessor :reproductive_stage, :reproductive_clock, :estrous_clock, :estrous_cycle_length
  #TODO: set active_hours and movement_rates according to time of year or reproductive phase

  def initialize
    super
    self.reproductive_clock = 0
    self.estrous_clock = 0
    set_anestrus
    self.estrous_cycle_length = rand(2) + 3
  end

  def move
    forage
    tick_reproductive_clock
    check_death
  end


  def tick_reproductive_clock
    if impregnated?
      self.reproductive_clock += 1
    end
  end


  def tick_reproductive_clock

    if impregnated?
      self.reproductive_clock += 1
    end

    if (5..200).include? self.reproductive_clock
      set_gestation
      self.reproductive_clock += 1
    end

    if self.reproductive_clock == 201
        set_parturition
        give_birth
        self.reproductive_clock += 1
    end

    if (201..260).include? self.reproductive_clock
      set_lactation
      self.reproductive_clock += 1
    end

    if self.reproductive_clock > 260
      set_anestrus
      self.reproductive_clock += 1
    end

    # Rut behavior
    if rut? and (age > 365)
      if anestrus?
        self.estrous_clock = rand(estrous_cycle_length) + 1
        set_di_metestrus
      end

      if di_metestrus?
        self.estrous_clock += 1
        if self.estrous_clock > self.estrous_cycle_length
          set_estrus
          self.estrous_clock = 0
        end
      end

      if estrus?
        self.estrous_clock += 1
        if self.estrous_clock > self.estrous_cycle_length
          set_di_metestrus
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
  end

end



