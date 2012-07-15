require 'date'

class World
  attr_accessor :height, :width, :patches, :current_date

  def initialize(options = {})
    self.height = options[:height]
    self.width = options[:width]
    self.current_date = Date.new

    self.patches = {}

    width.times do |x|
      height.times do |y|
        patch = Patch.new
        patch.x, patch.y = x, y
        patches[patch_key(x,y)] = patch
      end
    end
  end

  def day_of_year
    current_date.yday
  end

  def patch(x,y)
    patches[patch_key(x,y)]
  end

  def patch_key(x,y)
    "#{x.floor}-#{y.floor}"
  end

  def patches_in_radius(center_x, center_y, radius)
    patch_list = []
    width.times do |patch_x|
      height.times do |patch_y|
        patch = patch(patch_x,patch_y)
        patch_list << patch if tile_in_range?(patch_x, patch_y, center_x, center_y, radius)
      end
    end
    patch_list
  end

  def tile_in_range? patch_x, patch_y, x, y, radius
    return false if patch_x < 0 || patch_x >= width || patch_y < 0 || patch_y >= height
    return true if patch_x == x.floor && patch_y == y.floor

    if patch_x == x.floor
      return (patch_y < y && patch_y + 1 > y - radius) || (patch_y > y && patch_y < y + radius)

    elsif patch_y == y.floor
      return (patch_x < x && patch_x + 1 > x - radius) || (patch_x > x && patch_x < x + radius)

    else
      x_offset = x - (patch_x < x ? patch_x + 1 : patch_x)
      y_offset = y - (patch_y < y ? patch_y + 1 : patch_y)
      dist = x_offset * x_offset + y_offset * y_offset
      return dist < radius * radius
    end
  end
end
