module DBBindings
  class Megatile < ActiveRecord::Base
    belongs_to :world
    has_many :resource_tiles
  end
end