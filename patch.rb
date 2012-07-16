class Patch
  attr_accessor :x, :y
  attr_accessor :marten_id, :marten_scent_age
  attr_accessor :land_cover_class

  attr_accessor :max_vole_pop
  attr_accessor :vole_population

  MAX_VOLE_POP = 13.9

  def initialize
    self.land_cover_class = :barren
    self.vole_population = 0
    self.max_vole_pop = MAX_VOLE_POP
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
      self.marten_id = nil
    end
  end
end
