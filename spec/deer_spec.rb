require File.dirname(__FILE__) + '/../male_deer'
require File.dirname(__FILE__) + '/../female_deer'

describe MaleDeer do
  context "big happy family" do
  let!(:world) { World.new width: 300, height: 300 }
  let!(:male_deers) { MaleDeer.spawn_population world, 2 }
  let(:male_deer) { male_deers.first }
  let(:male_deer_2) { male_deers[1] }
  let!(:female_deers) { FemaleDeer.spawn_population world, 2 }
  let(:female_deer) { female_deers.first }
  let(:female_deer_2) { female_deers[1] }


  before do
    male_deer.location = [1.5, 1.5]
    male_deer_2.location = [1.1, 1.1]
    female_deer.location = [2.5, 2.5]
    female_deer.age = 366
    female_deer_2.location = [0.5, 0.5]
    female_deer.age = 366
  end

# describe and before executed immediately prior to each it (to set it up)

  it 'ticks' do
    male_deer.tick
  end

  describe 'ticks during rut' do
    before do
      world.stubs :day_of_year => 270
      male_deer.stubs :active_hours => 1
      male_deer_2.stubs :active_hours => 1
    end


    it 'ticks2' do
      male_deer_2.tick
    end


    it 'chases the ladies' do
      male_deer.stubs :succesfully_mated? => true
      female_deer.stubs :reproductive_stage => :estrus
      female_deer_2.stubs :reproductive_stage => :di_metestrus
      puts "beginning location = #{male_deer.location}"
      male_deer.tick
      puts "end location = #{male_deer.location}"
      [female_deer.patch].include?(male_deer.patch).should == true
    end
  end


  it 'does 365 ticks' do
    365.times{ world.tick 
      world.stubs :day_of_year => world.day_of_year + 1
    puts "doy = #{world.day_of_year}"
    puts "male deer 1 energy = #{male_deer.energy}"
    puts "male deer 2 energy = #{male_deer_2.energy}"
    puts "female deer 1 energy = #{female_deer.energy}"
    puts "female_deer 2 energy = #{female_deer_2.energy}" 
    puts "female_deer 1 reproductive stage = #{female_deer.reproductive_stage}"
    puts "female_deer 2 reproductive stage = #{female_deer_2.reproductive_stage}"
    }
 end


  it 'dies' do
    puts 1000.times.collect{(365*male_deer.active_hours).times.select{ male_deer.die_from_mortality_trial? }.count}.mean
    #1000000000.times do
    #  raise 'whee' if male_deer.die_from_mortality_trial?
    #end
  end


  it 'checks agents on patch' do
    puts male_deer.x
    puts male_deer.y
    puts male_deer.patch
    puts world.patch(1,1)
    male_deer.patch.agents.count.should == 2
    male_deer.patch.agents.should == [male_deer, male_deer_2]
  end


  it 'counts the number of agents around it' do
    male_deer.agents_in_radius(1).count.should == 3
  end


  describe 'evaluate neighborhood for forage' do
    let!(:world) { World.new width: 3, height: 3}
    let(:young_coniferous) { Patch.new }
    let(:medium_coniferous) { Patch.new }
     let(:old_coniferous) { Patch.new }
     let(:young_deciduous) { Patch.new }
     let(:medium_deciduous) { Patch.new }
     let(:old_deciduous) { Patch.new }
     let(:young_mixed) { Patch.new }
     let(:medium_mixed) { Patch.new }
     let(:old_mixed) { Patch.new }
     let(:bunk_patch) { Patch.new }
     let(:forested_wetland) { Patch.new }

    context 'with range of basal area values' do
      before do
        young_coniferous.basal_area = 25
        young_coniferous.land_cover_class = :coniferous
        young_coniferous.site_index = 100
        medium_coniferous.basal_area = 90
        medium_coniferous.land_cover_class = :coniferous
        medium_coniferous.site_index = 90
        old_coniferous.basal_area = 150
        old_coniferous.land_cover_class = :coniferous
        old_coniferous.site_index = 80
        young_deciduous.basal_area = 25
        young_deciduous.land_cover_class = :deciduous
        young_deciduous.site_index = 70
        medium_deciduous.basal_area = 90
        medium_deciduous.land_cover_class = :deciduous
        medium_deciduous.site_index = 60
        old_deciduous.basal_area = 150
        old_deciduous.land_cover_class = :deciduous
        old_deciduous.site_index = 50
        young_mixed.basal_area = 25
        young_mixed.land_cover_class = :mixed
        young_mixed.site_index = 40
        medium_mixed.basal_area = 90
        medium_mixed.land_cover_class = :mixed
        medium_mixed.site_index = 30
        old_mixed.basal_area = 150
        old_mixed.land_cover_class = :mixed
        old_mixed.site_index = 20
        bunk_patch.basal_area = 0
        bunk_patch.land_cover_class = :barren
        forested_wetland.basal_area = 80
        forested_wetland.land_cover_class = :forested_wetland
        forested_wetland.site_index = 80
      end


      it 'checks browse availability' do
        male_deer.browse_availability_index(young_coniferous).should == 1
        male_deer.browse_availability_index(medium_coniferous).should == 0
        male_deer.browse_availability_index(old_coniferous).should == 0.5
        male_deer.browse_availability_index(young_deciduous).should == 1
        male_deer.browse_availability_index(medium_deciduous).should == 0
        male_deer.browse_availability_index(old_deciduous).should == 0.5
      end


      it 'evaluates browse quality index' do
        male_deer.browse_quality_index(young_coniferous).should == 1.0
        male_deer.browse_quality_index(medium_coniferous).should == 1.0
        male_deer.browse_quality_index(old_coniferous).should == 1.0
        male_deer.browse_quality_index(young_deciduous).should == 0.2
        male_deer.browse_quality_index(medium_deciduous).should == 0.2
        male_deer.browse_quality_index(old_deciduous).should == 0.2
      end


      it 'checks browse index' do
        male_deer.browse_index(young_coniferous).should == 1.0
        male_deer.browse_index(medium_coniferous).should == 0.5
        male_deer.browse_index(old_coniferous).should == 0.75
        male_deer.browse_index(young_deciduous).should == 0.6
        male_deer.browse_index(medium_deciduous).should == 0.1
        male_deer.browse_index(old_deciduous).should == 0.35
      end


      it 'evaluates mast index' do
        male_deer.mast_index(young_coniferous).should == 0.0
        male_deer.mast_index(medium_coniferous).should == 0.0
        male_deer.mast_index(old_coniferous).should == 0.0
        male_deer.mast_index(young_deciduous).should == 1.0
        male_deer.mast_index(medium_deciduous).should == 1.0
        male_deer.mast_index(old_deciduous).should == 1.0
        male_deer.mast_index(young_mixed).should == 0.5
        male_deer.mast_index(medium_mixed).should == 0.5
        male_deer.mast_index(old_mixed).should == 0.5
      end


      it 'evaluates site productivity index' do
        male_deer.site_productivity_index(young_coniferous).should == 1.0
        male_deer.site_productivity_index(medium_coniferous).should == 0.9
        male_deer.site_productivity_index(old_coniferous).should == 0.8
        male_deer.site_productivity_index(young_deciduous).should == 0.7
        male_deer.site_productivity_index(medium_deciduous).should == 0.6
        male_deer.site_productivity_index(old_deciduous).should == 0.5
        male_deer.site_productivity_index(young_mixed).should == 0.4
        male_deer.site_productivity_index(medium_mixed).should == 0.3
        male_deer.site_productivity_index(old_mixed).should == 0.2
      end


      it 'evalutes the suitability of patches in winter' do
        # ((2 * browse_index(patch) + mast_index(patch)) / 3) * site_productivity_index(patch)
        male_deer.assess_fall_winter_food_potential(young_coniferous).should be_within(0.00001).of(0.666666)
        male_deer.assess_fall_winter_food_potential(medium_coniferous).should == 0.3
        male_deer.assess_fall_winter_food_potential(old_coniferous).should == 0.4
        male_deer.assess_fall_winter_food_potential(young_deciduous).should be_within(0.000001).of(0.51333333)
        male_deer.assess_fall_winter_food_potential(medium_deciduous).should == be_within(0.000001).of(0.24)
        male_deer.assess_fall_winter_food_potential(old_deciduous).should be_within(0.000001).of(0.28333333)
        male_deer.assess_fall_winter_food_potential(young_mixed).should be_within(0.00001).of(0.2266666666)
        male_deer.assess_fall_winter_food_potential(medium_mixed).should be_within(0.000001).of(0.07)
        male_deer.assess_fall_winter_food_potential(old_mixed).should == 0.08
      end

      it 'provides a vegetation type index' do
        male_deer.vegetation_type_index(young_coniferous).should == 0.4
        male_deer.vegetation_type_index(medium_coniferous).should == 0.4
        male_deer.vegetation_type_index(old_coniferous).should == 0.4
        male_deer.vegetation_type_index(young_deciduous).should == 1.0
        male_deer.vegetation_type_index(medium_deciduous).should == 1.0
        male_deer.vegetation_type_index(old_deciduous).should == 1.0
        male_deer.vegetation_type_index(young_mixed).should == 1.0
        male_deer.vegetation_type_index(medium_mixed).should == 1.0
        male_deer.vegetation_type_index(old_mixed).should == 1.0
        male_deer.vegetation_type_index(forested_wetland).should == 0.2
        male_deer.vegetation_type_index(bunk_patch).should == 0.0
      end
    
      it 'provides a successional stage index' do # ba's = 25 90 150
        male_deer.successional_stage_index(young_coniferous).should == 1.0
        male_deer.successional_stage_index(medium_coniferous).should == 0.5
        male_deer.successional_stage_index(old_coniferous).should == 0.5
        male_deer.successional_stage_index(young_deciduous).should == 1.0
        male_deer.successional_stage_index(medium_deciduous).should == 0.2
        male_deer.successional_stage_index(old_deciduous).should == 0.2
        male_deer.successional_stage_index(young_mixed).should == 1.0
        male_deer.successional_stage_index(medium_mixed).should == 0.2
        male_deer.successional_stage_index(old_mixed).should == 0.2
        male_deer.successional_stage_index(forested_wetland).should == 0.2
        male_deer.successional_stage_index(bunk_patch).should == 0.0
      end


      it 'evaluates the suitability of patches in summer' do # veg type x successional stage x productivity
        male_deer.assess_spring_summer_food_potential(young_coniferous).should == 0.4
        male_deer.assess_spring_summer_food_potential(medium_coniferous).should be_within(0.00001).of(0.18)
        male_deer.assess_spring_summer_food_potential(old_coniferous).should be_within(0.000001).of(0.16)
        male_deer.assess_spring_summer_food_potential(young_deciduous).should == 0.7
        male_deer.assess_spring_summer_food_potential(medium_deciduous).should == 0.12
        male_deer.assess_spring_summer_food_potential(old_deciduous).should == 0.1
        male_deer.assess_spring_summer_food_potential(young_mixed).should be_within(0.0000001).of(0.4)
        male_deer.assess_spring_summer_food_potential(medium_mixed).should == 0.06
        male_deer.assess_spring_summer_food_potential(old_mixed).should be_within(0.0000001).of(0.04)
        male_deer.assess_spring_summer_food_potential(forested_wetland).should be_within(0.0000001).of(0.032)
        male_deer.assess_spring_summer_food_potential(bunk_patch).should == 0.0
      end


      it 'assesses the forest composition index' do # BA = 25 90 150
        male_deer.forest_composition_index(young_coniferous).should == 0.4
        male_deer.forest_composition_index(medium_coniferous).should == 1.0
        male_deer.forest_composition_index(old_coniferous).should == 1.0
        male_deer.forest_composition_index(young_deciduous).should == 0.0
        male_deer.forest_composition_index(medium_deciduous).should == 0.0
        male_deer.forest_composition_index(old_deciduous).should == 0.0
        male_deer.forest_composition_index(young_mixed).should == 0.2 
        male_deer.forest_composition_index(medium_mixed).should == 0.2
        male_deer.forest_composition_index(old_mixed).should == 0.2
        male_deer.forest_composition_index(forested_wetland).should == 0.0
        male_deer.forest_composition_index(bunk_patch).should == 0.0
      end


      it 'assesses the forest structure index' do # BA = 25 90 150     (2 x ((BA_index + canopy_cover_index + DBH_index) / 3) + age_structure_index) / 2
        male_deer.forest_structure_index(young_coniferous).should be_within(0.00001).of(0.66666)    # 2 * ((0.0 + 0.5 + 0.0) / 3) + 1.0) / 2 = 0.66666
        male_deer.forest_structure_index(medium_coniferous).should be_within(0.00001).of(0.5)       # 2 * ((0.5 + 1.0 + 0.0) / 3) + 0.0) / 2 = 0.5
        male_deer.forest_structure_index(old_coniferous).should be_within(0.00001).of(0.66666)      # 2 * ((1.0 + 1.0 + 0.0) / 3) + 0.0) / 2 = 0.66666
        male_deer.forest_structure_index(young_deciduous).should be_within(0.00001).of(0.66666)     # 2 * ((0.0 + 0.5 + 0.0) / 3) + 1.0) / 2 = 0.66666
        male_deer.forest_structure_index(medium_deciduous).should be_within(0.00001).of(0.5)        # 2 * ((0.5 + 1.0 + 0.0) / 3) + 0.0) / 2 = 0.5
        male_deer.forest_structure_index(old_deciduous).should be_within(0.00001).of(0.66666)       # 2 * ((1.0 + 1.0 + 0.0) / 3) + 0.0) / 2 = 0.66666
        male_deer.forest_structure_index(young_mixed).should be_within(0.00001).of(0.66666)         # 2 * ((0.0 + 0.5 + 0.0) / 3) + 1.0) / 2 = 0.66666
        male_deer.forest_structure_index(medium_mixed).should be_within(0.00001).of(0.5)            # 2 * ((0.5 + 1.0 + 0.0) / 3) + 0.0) / 2 = 0.5
        male_deer.forest_structure_index(old_mixed).should be_within(0.00001).of(0.66666)           # 2 * ((1.0 + 1.0 + 0.0) / 3) + 0.0) / 2 = 0.66666
        male_deer.forest_structure_index(forested_wetland).should be_within(0.00001).of(0.5)        # 2 * ((0.5 + 1.0 + 0.0) / 3) + 0.0) / 2 = 0.66666
        male_deer.forest_structure_index(bunk_patch).should be_within(0.00001).of(0.0)              # 2 * ((0.0 + 0.0 + 0.0) / 3) + 0.0) / 2 = 0.0
      end


      it 'returns the suitability for an unhappy patch in winter' do
        # happy_little_patch.land_cover_class = :developed_high_intensity
        male_deer.assess_fall_winter_food_potential(bunk_patch).should == 0
      end

      it 'returns the correct number of patches in neighborhood' do
        male_deer.neighborhood_in_radius(1).kind_of?(Array).should be_true
        male_deer.neighborhood_in_radius(1).count.should == 8
      end
      
      it 'selects the patch with highest score' do
        patches = Array[young_coniferous, medium_coniferous, old_coniferous, young_deciduous, medium_deciduous, old_deciduous, young_mixed, medium_mixed, old_mixed]
        # male_deer.select_highest_score_of_patch_set(patches).should == young_coniferous
        #binding.pry
        male_deer.patch_with_highest_score(patches)[0].should == young_coniferous
      end

    end
 end


  describe '#patches_in_radius' do
    it 'returns neighborhood of 1 from center of patch' do
      male_deer.location = [1.5, 1.5]
      male_deer.neighborhood_in_radius(1).collect(&:location).to_set.should == [[0,2],[1,2],[2,2],
                                                                             [0,1],      [2,1],
                                                                             [0,0],[1,0],[2,0]].to_set
    end

    it 'returns neighborhood of 1 from corner of patch' do
      male_deer.location = [1.9, 1.9]
      male_deer.neighborhood_in_radius(1).collect(&:location).to_set.should == [[0,2],[1,2],[2,2],
                                                                             [0,1],      [2,1],
                                                                                   [1,0],[2,0]].to_set
    end

    it 'returns neighborhood of 1 from corner of world' do
      male_deer.location = [0.1, 0.1]
      male_deer.neighborhood_in_radius(1).collect(&:location).to_set.should == [
                                                                             [0,1],
                                                                                   [1,0]      ].to_set
    end

    it 'returns neighborhood of 1 from corner of world' do
      male_deer.location = [0.0, 0.0]
      male_deer.neighborhood_in_radius(1).collect(&:location).to_set.should == [

                                                                                              ].to_set
    end
  end



  describe '#evaluate_neighborhood_for_forage in summer' do
    let!(:world) { World.new width: 3, height: 3}
    let(:happy_little_patch) { Patch.new }

    before do
      puts "day o' year:"
      puts world.day_of_year
      world.stubs :day_of_year => 90
      puts world.day_of_year
      # world.day_of_year = 90
    end

    it 'returns the suitability for a happy patch in summer' do
      happy_little_patch.land_cover_class = :deciduous
      male_deer.assess_spring_summer_food_potential(happy_little_patch).should > 0
    end

    it 'returns the suitability for an unhappy patch in summer' do
      happy_little_patch.land_cover_class = :developed_high_intensity
      male_deer.assess_spring_summer_food_potential(happy_little_patch).should == 0
    end
  end


  it 'yards'
  it 'eats'
  it 'matures'
  it 'seeks thermal cover in winter'


  # Mabes
  it 'moves to cover at the end of the day'

#  describe "#forage_distance" do
#    it "is 1000 meters per hour" do
#      male_marten.forage_distance.should be_within(0.001).of(15.7183)
#    end
#  end
  #
  end

  describe 'mating' do
    let!(:world) { World.new width: 1, height: 1}
    let!(:male_deer)   { MaleDeer.spawn_population(world, 1).first }
    let!(:female_deer) { FemaleDeer.spawn_population(world, 1).first }

    before do
      male_deer.location = world.all_patches.first.location
      female_deer.location = world.all_patches.first.location

      female_deer.set_estrus
    end

    it 'impregnates a female on patch' do
      male_deer.stubs :succesfully_mated? => true
      male_deer.attempt_to_mate
      female_deer.impregnated?.should == true
    end

    it 'does not impregnate female on patch' do
      male_deer.stubs :succesfully_mated? => false
      male_deer.attempt_to_mate
      female_deer.impregnated?.should == false
    end
  end
end
