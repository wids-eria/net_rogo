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
db_world = DBBindings::World.find world_id

puts 'world'
world = World.import_from_db(db_world)
world.job_name = Time.now.to_i.to_s

puts "\twidth = #{world.width}, height = #{world.height}"

#world.to_png

#RubyProf.start

ProgressBar.color_status
ProgressBar.iter_rate_mode
bar = ProgressBar.new 'ticks', 730 
730.times{ world.tick; bar.inc } # world.to_png; 
bar.finish

puts "Syncing state TO database"
ActiveRecord::Base.transaction do
  db_world.year_current = world.current_date.year
  db_world.save!
  
  puts "\tFlushing old DB Martens"
  #delete current martens in the db
  DBBindings::Marten.where(:world_id => db_world.id).each do |marten|
    marten.destroy
  end
  
  puts "\tSpawning #{world.martens.count} new DB Martens"
  #spawn new db martens
  world.martens.each do |marten|
    klass = case marten.class
    when MaleMarten
      DBBindings::MaleMarten
    when FemaleMarten
      DBBindings::FemaleMarten
    else 
      raise "unknown marten class to save out to"
    end
    db_marten = klass.new :world_id => db_world.id, :x => marten.x, :y => marten.y, :age => marten.age
    db_marten.save!
  end
  how_many_db_martens = DBBindings::Marten.where(:world_id => db_world.id).count
  puts "\t\t#{how_many_db_martens} saved!"
  
  puts "\tSaving patch info"
  #write out patch info (for voles at this point)
  ProgressBar.color_status
  ProgressBar.iter_rate_mode
  bar = ProgressBar.new 'patches', world.width * world.height 
  world.all_patches.each do |patch|
    patch.sync_to_db
    bar.inc
  end
  bar.finish
  
end

#result = RubyProf.stop

# Print a flat profile to text
#printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT)
