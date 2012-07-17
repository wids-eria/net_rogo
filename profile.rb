require 'ruby-prof'
require File.dirname(__FILE__) + '/male_marten'

# Profile the code

puts 'world'
world = World.new width: 3000, height: 3000

puts 'spawning'
martens = MaleMarten.spawn_population world, 1000

RubyProf.start

puts 'ticking'
1.times{ print '.'; world.tick }

result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
