module DBBindings
  class ResourceTile < ActiveRecord::Base
    belongs_to :megatile
    belongs_to :world
    
    
    def self.cover_types
      @cover_types ||= { 11 => :open_water,
                         21 => :developed_open_space,
                         22 => :developed_low_intensity,
                         23 => :developed_medium_intensity,
                         24 => :developed_high_intensity,
                         31 => :barren,
                         41 => :deciduous,
                         42 => :coniferous,
                         43 => :mixed,
                         51 => :dwarf_scrub,
                         52 => :shrub_scrub,
                         71 => :grassland_herbaceous,
                         81 => :pasture_hay,
                         82 => :cultivated_crops,
                         90 => :forested_wetland,
                         95 => :emergent_herbaceous_wetland,
                         255 => :excluded }
    end

    def self.cover_type_symbol class_code
      cover_types[class_code] || :unknown
    end

    def self.cover_type_number class_symbol
      cover_types.invert[class_symbol.to_sym] || raise("Cover type #{class_symbol} not found")
    end
    
    
    def land_cover_type
      ResourceTile.cover_type_symbol self.landcover_class_code
    end

    def land_cover_type= val
      self.landcover_class_code = ResourceTile.cover_type_number val
    end
    
    
  end

  class LandTile < ResourceTile 
  end

  class WaterTile < ResourceTile 
  end
end  