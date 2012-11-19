module DBBindings
  class World < ActiveRecord::Base
    #self.table_name = "worlds"
    has_many :megatile
    has_many :resource_tiles
  end  
end
