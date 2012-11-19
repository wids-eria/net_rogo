require 'rubygems'
require 'bundler/setup'

require File.dirname(__FILE__) + '/db_connector'
require File.dirname(__FILE__) + '/db_models/world'
require File.dirname(__FILE__) + '/db_models/agent'
require File.dirname(__FILE__) + '/db_models/megatile'
require File.dirname(__FILE__) + '/db_models/resource_tile'

require File.dirname(__FILE__) + '/male_marten'
require File.dirname(__FILE__) + '/female_marten'
require 'chunky_png'
require 'progressbar'

puts "Command line arguments = #{ARGV}"
world_id = ARGV.first.to_i
if world_id == nil
  raise "You must specify a World ID to use!"
end
puts "Using World ID = #{world_id}"

puts 'world'
world = World.import_from_db(DBBindings::World.find world_id)
world.job_name = Time.now.to_i.to_s

puts "\twidth = #{world.width}, height = #{world.height}"



#world.to_png

#RubyProf.start

ProgressBar.color_status
ProgressBar.iter_rate_mode
bar = ProgressBar.new 'ticks', 730 
730.times{ world.tick; bar.inc } # world.to_png; 
bar.finish

#result = RubyProf.stop

# Print a flat profile to text
#printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT)
