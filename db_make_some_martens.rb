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
  
  How_many_martens = (10.0/(128*128) * db_world.width * db_world.height * 0.5).ceil # Steve estimates 10 for an eagle-sized area. We cut in half so we can do this many males and females
  if db_male_martens.count == 0
    resource_tiles = db_world.resource_tiles.where(:landcover_class_code => 42).order("RAND()").limit(10)
    resource_tiles.each do |rt|
      db_marten = DBBindings::MaleMarten.new :world_id => db_world.id, :x => rt.x, :y => rt.y, :age => 730
    end
  end

  if db_female_martens.count == 0
    resource_tiles = db_world.resource_tiles.where(:landcover_class_code => 42).order("RAND()").limit(10)
    resource_tiles.each do |rt|
      db_marten = DBBindings::FemaleMarten.new :world_id => db_world.id, :x => rt.x, :y => rt.y, :age => 730
    end
  end
end

puts "Spawning voles into patches"
class_codes_to_stick_voles_in = [31,41,42,43,52,71]
tiles_that_need_voles = db_world.resource_tiles.where(:landcover_class_code => class_codes_to_stick_voles_in).where(:vole_population => 0)
tiles_that_need_voles.update_all(:vole_population => Patch::MAX_VOLE_POP)

