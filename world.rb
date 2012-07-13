class World
  attr_accessor :height, :width, :patches

  def initialize(options = {})
    puts "creating world with #{options.inspect}"
    self.height = options[:height]
    self.width = options[:width]

    self.patches = {}

    width.times do |x|
      height.times do |y|
        patch = Patch.new
        patch.x, patch.y = x, y
        patches["#{x}-#{y}"] = patch
      end
    end
  end

  def patch(x,y)
    patches["#{x.floor}-#{y.floor}"]
  end
end
