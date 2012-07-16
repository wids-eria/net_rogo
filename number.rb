class Numeric
  def day
    self
  end

  def degrees
    self
  end

  def radians
    self
  end

  def in_radians
   self * (Math::PI/180.0)
  end

  def in_degrees
    self * (180.0/Math::PI)
  end
end

# you could do clever things with an attribute or subclass (Radian, Degree) to
# make dealing with either transparent
