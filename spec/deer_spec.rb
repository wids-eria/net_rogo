require File.dirname(__FILE__) + '/../male_deer'

describe MaleDeer do
  let!(:world) { World.new width: 300, height: 300 }
  let!(:deers) { MaleDeer.spawn_population world, 2 }
  let(:male_deer) { deers.first }
  let(:male_deer_2) { deers[1] }

  before do
    male_deer.location = [1.5, 1.5]
    male_deer_2.location = [1.1, 1.1]
  end

# describe and before executed immediately prior to each it (to set it up)

  it 'ticks' do
    male_deer.tick
  end


  it 'ticks2' do
    male_deer_2.tick
  end


  it 'does 365 ticks' do
    365.times{ world.tick }
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
    male_deer.agents_in_radius(1).count.should == 1
    male_deer.agents_in_radius(1).should == [male_deer_2]
  end


  describe 'evaluate_neighborhood_for_forage in winter' do
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
  
    context 'with range of basal area' do
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
        male_deer.assess_fall_winter_food_potential(young_coniferous).should == 6.0
        male_deer.assess_fall_winter_food_potential(medium_coniferous).should == 2.7
        male_deer.assess_fall_winter_food_potential(old_coniferous).should == 3.6
        male_deer.assess_fall_winter_food_potential(young_deciduous).should == 4.62
        male_deer.assess_fall_winter_food_potential(medium_deciduous).should be_within(0.00001).of(2.16)
        male_deer.assess_fall_winter_food_potential(old_deciduous).should == 2.55
        male_deer.assess_fall_winter_food_potential(young_mixed).should == 2.04
        male_deer.assess_fall_winter_food_potential(medium_mixed).should be_within(0.0001).of(0.63)
        male_deer.assess_fall_winter_food_potential(old_mixed).should == 0.72
      end
    end


    it 'returns the suitability for an unhappy patch in winter' do
      # happy_little_patch.land_cover_class = :developed_high_intensity
      male_deer.assess_fall_winter_food_potential(bunk_patch).should == 0
    end

    it 'selects the patch with highest score'

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

    it 'assesses vegetation type index'
    it 'evaluates successional stage index'
    it 'evaluates site productivity index'

    it 'returns the suitability for a happy patch in summer' do
      happy_little_patch.land_cover_class = :deciduous
      male_deer.assess_spring_summer_food_potential(happy_little_patch).should > 0
    end

    it 'returns the suitability for an unhappy patch in summer' do
      happy_little_patch.land_cover_class = :developed_high_intensity
      male_deer.assess_spring_summer_food_potential(happy_little_patch).should == 0
    end
  end
  
  
  it 'chases ladies during rut'
  it 'picks a destination after evaluating the neighborhood'
  it 'seeks thermal cover in winter'


  # Mabes
  it 'moves to cover at the end of the day'

#  describe "#forage_distance" do
#    it "is 1000 meters per hour" do
#      male_marten.forage_distance.should be_within(0.001).of(15.7183)
#    end
#  end

end
