require File.dirname(__FILE__) + '/../male_marten'

describe MaleMarten do
  let!(:world) { World.new width: 3, height: 3 }
  let(:male_marten) { MaleMarten.new }

  before do
    male_marten.world = world
  end

  it 'ticks' do
   male_marten.tick
  end

  describe '#location' do
    it 'returns x and y' do
      male_marten.x = 5.0
      male_marten.y = 6.0
      male_marten.location.should == [5.0, 6.0]
    end
  end

  describe "#forage_distance" do
    it "is 1000 meters per hour" do
      male_marten.forage_distance.should be_within(0.001).of(15.7183)
    end
  end

  describe '#stay_probability' do
    let(:max_energy) { MaleMarten::MAX_ENERGY }
    let(:stay_probability) { 0.97 }
    it 'is 97% when full' do
      male_marten.energy = max_energy
      male_marten.stay_probability.should == stay_probability
    end

    it 'is 48.5% when half energy' do
      male_marten.energy = max_energy * 0.5
      male_marten.stay_probability.should == stay_probability * 0.5
    end

    it 'is 0% when starving' do
      male_marten.energy = 0
      male_marten.stay_probability.should == 0.0
    end

    it 'is over 97% when over stuffed' do
      male_marten.energy = max_energy + 1
      male_marten.stay_probability.should > stay_probability
    end

    it 'is below 0% when in the red' do
      male_marten.energy = -1.0
      male_marten.stay_probability.should < 0.0
    end
  end

  describe '#habitat_suitability_for' do
    let(:happy_little_patch) { Patch.new }

    it 'returns the suitability for a happy patch' do
      happy_little_patch.land_cover_class = :deciduous
      male_marten.habitat_suitability_for(happy_little_patch).should == 1
    end

    it 'returns the suitability for an unhappy patch' do
      happy_little_patch.land_cover_class = :barren
      male_marten.habitat_suitability_for(happy_little_patch).should == 0
    end
  end

  describe '#patches_in_radius' do
    it 'returns neighborhood of 1 from center of patch' do
      male_marten.location = [1.5, 1.5]
      male_marten.patches_in_radius(1).collect(&:location).to_set.should == [[0,2],[1,2],[2,2],
                                                                             [0,1],[1,1],[2,1],
                                                                             [0,0],[1,0],[2,0]].to_set
    end

    it 'returns neighborhood of 1 from corner of patch' do
      male_marten.location = [1.9, 1.9]
      male_marten.patches_in_radius(1).collect(&:location).to_set.should == [[0,2],[1,2],[2,2],
                                                                             [0,1],[1,1],[2,1],
                                                                                   [1,0],[2,0]].to_set
    end

    it 'returns neighborhood of 1 from corner of world' do
      male_marten.location = [0.0, 0.0]
      male_marten.patches_in_radius(1).collect(&:location).to_set.should == [

                                                                             [0,0]            ].to_set
    end
  end

  describe "daily cycle" do
    it "has 8 active hours in winter" do
      male_marten.stubs :growing_season? => false
      male_marten.active_hours.should == 8
    end

    it "has 12 active hours in the growing season" do
      male_marten.stubs :growing_season? => true
      male_marten.active_hours.should == 12
    end

    it "forages once for each active hour" do
      male_marten.stubs :active_hours => 5
      male_marten.expects(:hourly_routine).times(5)
      male_marten.forage
    end

    describe "hourly routine" do
      describe "moving" do
        context "when facing a suitable patch" do
          before do
            male_marten.heading = 180.degrees
            male_marten.location = [1.5, 1.5]
            male_marten.energy = 1000000
            @desired_patch = world.patch(0, 1)
            @desired_patch.land_cover_class = :deciduous
            @desired_patch.marten_id = nil
          end

          context "that is unscented" do
            it "goes to that patch because of his starting coordinates" do
              male_marten.move_one_patch
              male_marten.patch.should == @desired_patch
            end
          end
        end
        it 'backtracks with select forage patch if no suitable tiles' do
          male_marten.select_forage_patch
        end

        it 'goes to the tile with the largest vole population' do
          male_marten.select_forage_patch
        end
      end

      describe "hunting" do
        it "has a chance of detecting and killing voles"
      end

      describe "being eaten" do
        it "has higher probability of survival on suitable patch"
      end
    end
  end

  describe "starvation" do
    it "starves if he has no energy"
  end

  describe "metabolizing" do
    it "uses more energy in the growing season"
  end

  describe "stuffy stuff" do
    it "keeps heading within 2PI"
    it "increases heading if turning right"
  end
end
