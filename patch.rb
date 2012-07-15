class Patch
  attr_accessor :x, :y
  attr_accessor :marten_id
  attr_accessor :land_cover_class

  attr_accessor :max_vole_pop

  def residue
    {}
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


  def population
    {vole_population: 0}
  end
end
