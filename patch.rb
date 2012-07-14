class Patch
  attr_accessor :x, :y
  attr_accessor :marten_id
  attr_accessor :land_cover_class

  def residue
    {}
  end

  def location
    [self.x,self.y]
  end


  def population
    {vole_population: 0}
  end
end
