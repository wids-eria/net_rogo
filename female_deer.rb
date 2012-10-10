require File.dirname(__FILE__) + '/deer'
require File.dirname(__FILE__) + '/male_deer'
require File.dirname(__FILE__) + '/deer_reproductive_stages'

class FemaleDeer < Deer
  include DeerReproductiveStages

  attr_accessor :reproductive_stage, :reproductive_clock, :estrous_clock, :estrous_cycle_length
  #TODO: set active_hours and movement_rates according to time of year or reproductive phase

  BASE_HOURLY_METABOLIC_RATE = 1 # one hours caloric cost

  def hourly_metabolic_rate
    if impregnated? || anestrus? || estrus? || di_metestrus?
      modifier = 1.0
    elsif gestation? || lactation?
      modifier = 1.5
    elsif parturition?
      modifier = 3.0
    else
      raise 'unimplemented'
    end

    BASE_HOURLY_METABOLIC_RATE * modifier
  end

  def initialize
    super
    self.reproductive_clock = 0
    self.estrous_clock = 0
    set_anestrus
    self.estrous_cycle_length = rand(2) + 3
  end

  def move
    tick_reproductive_clock
    forage
    check_death
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
    self.active_hours.each do
      move_to_forage_patch_and_eat
      metabolize_hourly
    end

    evaluate_neighborhood_for_bedding(neighborhood_in_radius(1))
    move_to_cover
  end


  def metabolize_hourly
    self.energy -= hourly_metabolic_rate
  end

end



