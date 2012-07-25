require 'rubygems'
require 'bundler/setup'
require File.dirname(__FILE__) + '/male_marten'
require 'chunky_png'
require 'progressbar'

# Profile the code

puts 'world'
world = World.new width: 1351, height: 712
#world = World.new width: 100, height: 100

puts 'spawning'
martens = MaleMarten.spawn_population world, 100
martens = FemaleMarten.spawn_population world, 100
#RubyProf.start

ProgressBar.color_status
ProgressBar.iter_rate_mode
bar = ProgressBar.new 'ticks', 500
500.times{ world.tick; world.to_png; bar.inc }
bar.finish

#result = RubyProf.stop

# Print a flat profile to text
#printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT)
