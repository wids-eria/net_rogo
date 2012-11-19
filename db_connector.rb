require 'yaml'
require 'active_record'

dbconfig = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection dbconfig["development"]
 ActiveRecord::Base.store_full_sti_class = false

module DatabaseSync
  def self.included(base)
    puts "DatabaseSync INCLUDED!"
    base.extend ClassMethods
  end
  
  module ClassMethods    
    def sync_fields(*args)
      @fields_to_sync ||= [] 
      @fields_to_sync += args
    end
  end
  
  def sync_to_db
    self.class.instance_variable_get(:@fields_to_sync).each do |field|
      @sync_correspondent.send("#{field}=", self.send("#{field.to_s}"))
    end
    @sync_correspondent.save!
  end
  
  def sync_from_db
    self.class.instance_variable_get(:@fields_to_sync).each do |field|
      self.send("#{field.to_s}=", @sync_correspondent.send("#{field.to_s}"))
    end
  end
  
  def use_correspondent(correspondent)
    @sync_correspondent = correspondent
  end
end