require 'rubygems'
require 'bundler/setup'
require 'progressbar'


require File.dirname(__FILE__) + '/db_connector'
require File.dirname(__FILE__) + '/db_models/world'
require File.dirname(__FILE__) + '/db_models/agent'
require File.dirname(__FILE__) + '/db_models/megatile'
require File.dirname(__FILE__) + '/db_models/resource_tile'

require File.dirname(__FILE__) + '/world'
require File.dirname(__FILE__) + '/male_marten'
require File.dirname(__FILE__) + '/female_marten'

puts "Command line arguments = #{ARGV}"
world_id = ARGV.first.to_i
if world_id == nil
  raise "You must specify a World ID to use!"
end
puts "Using World ID = #{world_id}"

db_world = DBBindings::World.find world_id

db_male_martens = DBBindings::MaleMarten.where(:world_id => db_world.id)
db_female_martens = DBBindings::FemaleMarten.where(:world_id => db_world.id)

if (db_male_martens.count == 0) or (db_female_martens.count == 0) #ok, let's spawn a netrogo world
  puts "We need to make some martens!"
  
  How_many_martens = (10.0/(128*128) * db_world.width * db_world.height * 0.5).ceil
  world = World.import_from_db(db_world)
  if db_male_martens.count == 0
    puts "\tMaking #{How_many_martens} males"
    spawned_martens = MaleMarten.spawn_population world, How_many_martens
    spawned_martens.each do |marten|
      db_marten = DBBindings::MaleMarten.new :world_id => db_world.id, :x => marten.x, :y => marten.y, :age => 730
      db_marten.save!
    end
  end

  if db_female_martens.count == 0
    puts "\tMaking #{How_many_martens} females"
    spawned_martens = FemaleMarten.spawn_population world, How_many_martens
    spawned_martens.each do |marten|
      db_marten = DBBindings::FemaleMarten.new :world_id => db_world.id, :x => marten.x, :y => marten.y, :age => 730
      db_marten.save!
    end
  end
end

puts "Spawning voles into patches"
ProgressBar.color_status
ProgressBar.iter_rate_mode
class_codes_to_stick_voles_in = [31,41,42,43,52,71]
tiles_that_need_voles = db_world.resource_tiles.where(:landcover_class_code => class_codes_to_stick_voles_in).where(:vole_population => 0)
bar = ProgressBar.new 'patches', tiles_that_need_voles.count 
tiles_that_need_voles.each do |rt|
  rt.vole_population = Patch::MAX_VOLE_POP
  rt.save!
  bar.inc
end
bar.finish


