require 'date'

class World
  attr_accessor :height, :width, :patches, :martens, :current_date, :tick_count

  def initialize(options = {})
    self.height = options[:height]
    self.width = options[:width]
    self.current_date = Date.new
    self.martens = []
    self.tick_count = 0

    self.patches = Array.new(width) { Array.new(height) }

    width.times do |x|
      height.times do |y|
        patch = Patch.new
        patch.land_cover_class = :deciduous
        patch.vole_population = patch.max_vole_pop
        patch.x, patch.y = x, y
        set_patch(x, y, patch)
      end
    end
  end

  def all_patches
    patches.flatten
  end

  def tick
    martens.each(&:tick)
    all_patches.each(&:tick)
    self.current_date += 1.day
    self.tick_count += 1
  end

  def day_of_year
    current_date.yday
  end

  def set_patch(x,y, patch)
    patches[x.to_i][y.to_i] = patch
  end

  def patch(x,y)
    return nil if y >= height || y < 0 || x >= width || x < 0
    patches[x.to_i][y.to_i]
  end


  def patches_in_radius(center_x, center_y, radius)
    patch_list = []
    (((center_x-radius).floor)..((center_x+radius).ceil)).each do |patch_x|
      (((center_y-radius).floor)..((center_y+radius).ceil)).each do |patch_y|
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

  def to_png
    file_name = "world_tick_#{self.tick_count}.png"
    canvas = ChunkyPNG::Image.new self.width, self.height, ChunkyPNG::Color(:black)

    # interpolate 255 = all of 1st color, 0 = all of 2nd color

    all_patches.each do |patch|
      land_color = ChunkyPNG::Color(0,0,0)
      canvas[patch.x, patch.y] = land_color if patch.land_cover_class == :deciduous

      vole_color = ChunkyPNG::Color(100,0,100)
      alpha = 1 - patch.vole_population/patch.max_vole_pop #light up as it goes empty
      blender = ChunkyPNG::Color.interpolate_quick vole_color, land_color, (alpha * 255).to_i

      canvas[patch.x, patch.y] = blender

      if !patch.marten_scent_age.nil?
        scent_color = ChunkyPNG::Color(0,0,100)
        alpha = 1 - patch.marten_scent_age/14.0
        # TODO marten energy color in trail?
        blender = ChunkyPNG::Color.interpolate_quick scent_color, canvas[patch.x, patch.y], (alpha * 255).to_i

        canvas[patch.x, patch.y] = blender
      end
    end

    martens.each do |marten|
      happy_color = ChunkyPNG::Color(0,255,0)
      sad_color   = ChunkyPNG::Color(255,0,0)

      alpha = marten.energy/marten.max_energy
      blender = ChunkyPNG::Color.interpolate_quick happy_color, sad_color, (alpha * 255).to_i
      #canvas.circle marten.x.to_i, marten.y.to_i, 1, blender
      canvas[marten.x.to_i, marten.y.to_i] = blender
      # draw heading here
    end

    canvas.save file_name
  end
end
