module DeerLandscapeFunctions

    EXTENDED_HABITAT_ATTRIBUTES = { open_water:       {suitability: -1, forest_type_index: 0,   forest: 0},
                         developed_open_space:        {suitability: 1,  forest_type_index: 0,   forest: 0},
                         developed_low_intensity:     {suitability: 1,  forest_type_index: 0,   forest: 0},
                         developed_medium_intensity:  {suitability: 0,  forest_type_index: 0,   forest: 0},
                         developed_high_intensity:    {suitability: 0,  forest_type_index: 0,   forest: 0},
                         barren:                      {suitability: 0,  forest_type_index: 0,   forest: 0},
                         deciduous:                   {suitability: 1,  forest_type_index: 0,   forest: 1},
                         coniferous:                  {suitability: 1,  forest_type_index: 1,   forest: 1},
                         mixed:                       {suitability: 1,  forest_type_index: 0.5, forest: 1},
                         dwarf_scrub:                 {suitability: 1,  forest_type_index: 0,   forest: 0},
                         shrub_scrub:                 {suitability: 1,  forest_type_index: 0,   forest: 0},
                         grassland_herbaceous:        {suitability: 1,  forest_type_index: 0,   forest: 0},
                         pasture_hay:                 {suitability: 1,  forest_type_index: 0,   forest: 0},
                         cultivated_crops:            {suitability: 1,  forest_type_index: 0,   forest: 0},
                         forested_wetland:            {suitability: 1,  forest_type_index: 0,   forest: 1},
                         emergent_herbaceous_wetland: {suitability: 1,  forest_type_index: 0,   forest: 0},
                         excluded:                    {suitability: -1, forest_type_index: 0,   forest: 0}}


  def assess_thermal_cover
    #forest_composition_index x forest_structure_index x site_productivity_index
    forest_type_index = EXTENDED_HABITAT_ATTRIBUTES[self.land_cover_class][:forest_type_index]
    if forest_type_index > 0
      thermal_index = forest_composition_index * forest_structure_index * site_productivity_index
    else
      thermal_index = 0
    end
  end


  def forest_composition_index
    forest_type_index = EXTENDED_HABITAT_ATTRIBUTES[patch.land_cover_class][:forest_type_index]
    # TODO: currently cannot differentiate between conifer types; would be useful to implement general moisture regime (mesic/xeric)
      # Northern Hemlock, White Cedar = 1 (lowland/mesic conifers)
      # spruce and fir = 0.8 (woody wetlands)
      # pine = 0.4 (upland/xeric conifers)
    coniferous_species_index = 1
    forest_composition_index = forest_type_index * coniferous_species_index
  end


  def forest_structure_index(patch)
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


  def basal_area_index(patch)
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


  def assess_fall_winter_food_potential(patch)
     #forest_composition_index x forest_structure_index x site_productivity_index
     forest_index = EXTENDED_HABITAT_ATTRIBUTES[patch.land_cover_class][:forest]
     if forest_index > 0
       (2 * browse_index(patch) + mast_index(patch)) * 3 * site_productivity_index(patch)
     else
       0
     end
  end


    def browse_index(patch)
      (browse_quality_index(patch) + browse_availability_index(patch)) / 2
      #TODO: have to link to species-specific traits; upland/lowland x lcc?
    end


    def browse_availability_index(patch)
      # patches with high or low basal (young or old stands) area have browse available - totally just made this up
      if patch.basal_area < 30
        1.0
      elsif patch.basal_area > 120
        0.5
      else
        0
      end
    end


    def browse_quality_index(patch)
      # 0-1 ranking based on palatability and nutrition of species (Thuja occidentalis = 1, Abies balsema = 0.25, fill in the rest)
      # ideally early or late successional lowland conifers; for now we'll just say coniferous below or above certain BA
      if patch.land_cover_class == :coniferous
        1.0
      else
        0.2
      end
    end


    def mast_index(patch)
      if patch.land_cover_class == :deciduous
        1
      elsif patch.land_cover_class == :mixed
        0.5
      else
        0
      end
      #TODO: also species specific (oak and beech); upland/lowland x lcc?
    end


  def assess_spring_summer_food_potential(patch)
     #forest_composition_index x forest_structure_index x site_productivity_index
     forest_index = EXTENDED_HABITAT_ATTRIBUTES[patch.land_cover_class][:forest]
     if forest_index > 0
       vegetation_type_index(patch) * successional_stage_index(patch) * site_productivity_index(patch)
     else
       spring_summer_food_index = 0
     end
  end


  def vegetation_type_index(patch)
    # upland deciduous and mixed = 1
    # upland coniferous = 0.4
    # lowland (aquatic emergent plants) = 0.2 - probably just wetlands (woody and herbacious)
    if patch.land_cover_class = :deciduous or :mixed
      1
    elsif patch.land_cover_class = :coniferous
      0.4
    elsif patch.land_cover_class = :forested_wetland or :emergent_herbacious_wetlands
      0.2
    else
      0
    end
  end


  def successional_stage_index(patch)
    # TODO: these include bedding usage? wtf?
    # upland deciduous and mixed or lowland early successional = 1.0
    # upland deciduous and mixed or lowland mid-successional   = 0.6
    # upland deciduous and mixed or lowland late-successional  = 0.2
    # upland coniferous early- to mid-successional             = 1.0
    # upland coniferous late-successional                      = 0.5
    1
  end


  def site_productivity_index(patch)
    # TODO: tie max_site_index to stricter number
    max_site_index = 100.0
    patch.site_index / max_site_index
  end
end
