class Patch
  attr_accessor :x, :y
  attr_accessor :marten_id
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
end
