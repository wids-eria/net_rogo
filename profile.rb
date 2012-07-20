require 'ruby-prof'
require File.dirname(__FILE__) + '/male_marten'
require 'chunky_png'

# Profile the code

puts 'world'
#world = World.new width: 1351, height: 712
world = World.new width: 35, height: 35

puts 'spawning'
martens = MaleMarten.spawn_population world, 2 

RubyProf.start

puts 'ticking'
500.times{ print '.'; world.tick; world.to_png }

result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
