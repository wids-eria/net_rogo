module DeerReproductiveStages
  def impregnate
    self.reproductive_clock = 0
    self.reproductive_stage = :impregnated
  end

  def impregnated?
    self.reproductive_stage == :impregnated
  end


  def set_anestrus
    self.reproductive_stage = :anestrus
  end

  def anestrus?
    self.reproductive_stage == :anestrus
  end


  def set_estrus
    self.reproductive_stage = :estrus
  end

  def estrus?
    self.reproductive_stage == :estrus
  end


  def set_di_metestrus
    self.reproductive_stage = :di_metestrus
  end

  def di_metestrus?
    self.reproductive_stage == :di_metestrus
  end


  def set_gestation
    self.reproductive_stage = :gestation
  end

  def gestation?
    self.reproductive_stage == :gestation
  end


  def set_parturition
    self.reproductive_stage = :parturition
  end

  def parturition?
    self.reproductive_stage == :parturition
  end


  def set_lactation
    self.reproductive_stage = :lactation
  end

  def lactation?
    self.reproductive_stage == :lactation
  end
end
