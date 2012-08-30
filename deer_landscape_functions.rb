module DeerLandscapeFunctions
  
    HABITAT_ATTRIBUTES = { open_water:                  {suitability: -1, forest_type_index: 0},
                         developed_open_space:        {suitability: 1,  forest_type_index: 0},
                         developed_low_intensity:     {suitability: 1,  forest_type_index: 0},
                         developed_medium_intensity:  {suitability: 0,  forest_type_index: 0},
                         developed_high_intensity:    {suitability: 0,  forest_type_index: 0},
                         barren:                      {suitability: 0,  forest_type_index: 0},
                         deciduous:                   {suitability: 1,  forest_type_index: 0},
                         coniferous:                  {suitability: 1,  forest_type_index: 1},
                         mixed:                       {suitability: 1,  forest_type_index: 0.5},
                         dwarf_scrub:                 {suitability: 1,  forest_type_index: 0},
                         shrub_scrub:                 {suitability: 1,  forest_type_index: 0},
                         grassland_herbaceous:        {suitability: 1,  forest_type_index: 0},
                         pasture_hay:                 {suitability: 1,  forest_type_index: 0},
                         cultivated_crops:            {suitability: 1,  forest_type_index: 0},
                         forested_wetland:            {suitability: 1,  forest_type_index: 0},
                         emergent_herbaceous_wetland: {suitability: 1,  forest_type_index: 0},
                         excluded:                    {suitability: -1, forest_type_index: 0} }
  
  
  def assess_thermal_cover
    #forest_composition_index x forest_structure_index x site_productivity_index
    forest_type_index = HABITAT_ATTRIBUTES[self.land_cover_class][:forest_type_index]
    if forest_type_index > 0
      thermal_index = forest_composition_index * forest_structure_index * site_productivity_index
    else
      thermal_index = 0
    end
  end

 def forest_composition_index
   forest_type_index = HABITAT_ATTRIBUTES[patch.land_cover_class][:forest_type_index]
   # TODO: currently cannot differentiate between conifer types; would be useful to implement general moisture regime (mesic/xeric)
     # Northern Hemlock, White Cedar = 1 (lowland/mesic conifers)
     # spruce and fir = 0.8 (woody wetlands)
     # pine = 0.4 (upland/xeric conifers)
   coniferous_species_index = 1
   forest_composition_index = forest_type_index * coniferous_species_index
 end


 def forest_structure_index
   # TODO: finish this off when access to forest data is available
   basal_area_index = 1
     # 0 - 30.49 ft: 0
     # 30.49 - 100.19: 0.5
     # > 100.19 : 1
   diameter_index = 1
   canopy_cover_index = 1
   age_structure_index = 1
   forest_structure_index = (2 * ((basal_area_index + canopy_cover_index + diameter_index) / 3) + age_structure_index) / 3
 end

 def basal_area_index
   if 
     (0..30.49).include? patch.basal_area
     0
   elsif
     (30.49..100.19).include? patch.basal_area
     0.5
   else
     patch.basal_area > 100.19
     1
   end
 end


 def site_productivity_index
   max_site_index = 100
   patch.site_index/max_site_index 
 end

end
