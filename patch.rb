class Patch
  attr_accessor :x, :y
  attr_accessor :marten, :marten_scent_age
  attr_accessor :land_cover_class

  attr_accessor :max_vole_pop
  attr_accessor :vole_population

  MAX_VOLE_POP = 13.9
  UNHINDERED_VOLE_GROWTH_RATE = 0.00344

  def initialize
    self.land_cover_class = :barren
    self.max_vole_pop = MAX_VOLE_POP
    self.vole_population = self.max_vole_pop
  end

  def tick
    age_and_expire_scents
    grow_voles
  end

  def location
    [self.x,self.y]
  end

  def center_x
    self.x + 0.5
  end

  def center_y
    self.y + 0.5
  end

  def age_and_expire_scents
    return if self.marten_scent_age.nil?
    self.marten_scent_age += 1
    if marten_scent_age >= 14
      self.marten_scent_age = nil
      self.marten = nil
    end
  end

  def grow_voles
    density_dependent_growth_delta = daily_growth_delta * (1 - (self.vole_population/self.max_vole_pop))
    self.vole_population = self.vole_population + density_dependent_growth_delta * self.vole_population
  end

  def daily_growth_delta
    UNHINDERED_VOLE_GROWTH_RATE
  end
end
