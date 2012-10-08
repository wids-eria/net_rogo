require 'rubygems'
require 'bundler/setup'
require "active_record"
dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig['development'])

class Agent < ActiveRecord::Base

end

puts Agent.count
