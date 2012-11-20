require 'date'
require 'csv'
require 'fileutils'
require 'progressbar'


module Enumerable

    def sum
      self.inject(0){|accum, i| accum + i }
    end

    def mean
      self.sum/self.length.to_f
    end

    def sample_variance
      m = self.mean
      sum = self.inject(0){|accum, i| accum +(i-m)**2 }
      sum/(self.length - 1).to_f
    end

    def standard_deviation
      return Math.sqrt(self.sample_variance)
    end

end 

class World
  attr_accessor :height, :width, :patches, :martens, :deers, :current_date, :tick_count
  attr_accessor :job_name
  
  include DatabaseSync
  sync_fields :height, :width
  
  def self.import_from_db(db_world)
    world = self.new
    world.initialize_with_db_data(db_world)
    
    world
  end

  def self.import(filename)
    csv_rows = []
    CSV.foreach(filename) { |row| csv_rows << row }
    headers = csv_rows.shift
    x_pos = headers.index('ROW')
    y_pos = headers.index('COL')
    land_cover_pos = headers.index('LANDCOV2006')

    width  = csv_rows.collect{|row| row[x_pos].to_i}.max + 1
    height = csv_rows.collect{|row| row[y_pos].to_i}.max + 1

    world = self.new
    world.initialize_with_test_data(width: width, height: height)

    csv_rows.each do |csv_row|
      x = csv_row[x_pos].to_i
      y = csv_row[y_pos].to_i
      cover_code = csv_row[land_cover_pos].to_i
      patch = world.patch(x,y)
      patch.land_cover_from_code cover_code
    end

    puts world.all_patches.collect{|patch| patch.land_cover_class }.uniq.inspect

    world
  end

  def initialize(options = {})
    self.height = options[:height]
    self.width = options[:width]
    self.martens = []
    self.deers = []
    self.tick_count = 0
    self.job_name = "name_me"
  end

  def initialize_with_db_data(db_world)
    self.use_correspondent db_world
    self.sync_from_db
    
    self.current_date = Date.new(db_world.year_current)

    #load in tiles
    self.patches = Array.new(width) { Array.new(height) }
    
    ProgressBar.color_status
    ProgressBar.iter_rate_mode
    bar = ProgressBar.new 'patches', db_world.resource_tiles.count 
    
    db_world.resource_tiles.find_in_batches do |group|
      group.each do |rt|
        patch = Patch.new rt
        set_patch(rt.x, rt.y, patch)
        bar.inc
      end
    end
    bar.finish
    
    #load in martens
    db_male_martens = DBBindings::MaleMarten.where(:world_id => db_world.id)
    db_female_martens = DBBindings::FemaleMarten.where(:world_id => db_world.id)
    
    puts "\tfound #{db_male_martens.count} male and #{db_female_martens.count} female martens"
    
    db_male_martens.each do |db_male_marten|
      marten = MaleMarten.spawn_at(self, db_male_marten.x, db_male_marten.y)
      marten.age = 730
    end
    
    db_female_martens.each do |db_female_marten|
      marten = FemaleMarten.spawn_at(self, db_female_marten.x, db_female_marten.y)
      marten.age = 730
    end
    self
  end

  def initialize_with_test_data(options = {})
    self.current_date = Date.new

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
    self
  end

  def all_patches
    patches.flatten
  end

  def tick
    martens.each(&:tick)
    deers.each(&:tick)
    all_patches.each(&:tick)
    to_png
    self.current_date += 1.day
    self.tick_count += 1
    output_stats
  end

  def output_stats
    vole_population = all_patches.collect(&:vole_population)
    dir_name = File.join(self.job_name)
    FileUtils.mkdir_p(dir_name)
    CSV.open(File.join(dir_name, "vole_stats.csv"), "ab") do |csv_file|
      csv_file << [tick_count, martens.count, vole_population.standard_deviation, vole_population.mean]
    end
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
    dir_name = File.join(self.job_name, "tick_images")
    FileUtils.mkdir_p(dir_name)
    file_name = "world_tick_%05d.png" %self.tick_count 
    full_path = File.join(dir_name, file_name)
    canvas = ChunkyPNG::Image.new self.width, self.height

    # interpolate 255 = all of 1st color, 0 = all of 2nd color
    all_patches.each do |patch|
      vole_color  = ChunkyPNG::Color(100,0,100)
      patch_color = ChunkyPNG::Color(*patch.color)

      alpha = 1 - patch.vole_population/patch.max_vole_pop #light up as it goes empty
      blender = ChunkyPNG::Color.interpolate_quick vole_color, patch_color, (alpha * 255).to_i

      canvas[patch.x, patch.y] = blender

      if !patch.marten_scent_age.nil?
        scent_color = patch.marten.color.clone
        scent_color.saturation *= 0.5
        scent_color.lightness *= 0.75
        rgb = scent_color.to_rgb
        rgb = [rgb.red, rgb.green, rgb.blue].map(&:to_i)

        color = ChunkyPNG::Color(*rgb)

        canvas[patch.x, patch.y] = color
      end
    end

    martens.each do |marten|
      happy_color = ChunkyPNG::Color(0,255,0)
      sad_color   = ChunkyPNG::Color(255,0,0)

      alpha = marten.energy/marten.max_energy
      blender = ChunkyPNG::Color.interpolate_quick happy_color, sad_color, (alpha * 255).to_i

      if marten.kind_of? MaleMarten
        canvas.circle(marten.x.to_i, marten.y.to_i, 1, blender)
        canvas.circle(marten.x.to_i, marten.y.to_i, 2, blender)
      else
        canvas.circle(marten.x.to_i, marten.y.to_i, 1, blender)
      end
      # draw heading here
    end


      male_deer_color = ChunkyPNG::Color(139,69,19)
      female_deer_color   = ChunkyPNG::Color(222,184,135)

    deers.each do |deer|
      if deer.kind_of? MaleDeer
        canvas.circle(marten.x.to_i, marten.y.to_i, 1, male_deer_color)
      else
        canvas.circle(marten.x.to_i, marten.y.to_i, 1, female_deer_color)
      end
      # draw heading here
    end


    canvas.save full_path
  end


end
