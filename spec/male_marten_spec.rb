require File.dirname(__FILE__) + '/../male_marten'

RSpec.configure do |config|
  config.mock_framework = :mocha
end

describe MaleMarten do
  let!(:world) { World.new width: 3, height: 3 }
  let(:male_marten) { MaleMarten.new }

  before do
    male_marten.world = world
  end

  it 'ticks' do
   male_marten.tick
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
      it "is full when it has max energy"
      it "is not full when it has less than max energy"
      it "forages until its full"
      it "forages until it cant forage no mo"

      describe "moving" do
        it "moves one unit forward"

        context "when facing a suitable tile" do
          before do
            male_marten.heading = 180.degrees
            male_marten.location = [1.5, 1.5]
            @desired_patch = world.patch(0, 1)
            @desired_patch.marten_id = nil
          end

          context "that is unscented" do
            it "goes to that tile because of his starting coordinates" do
              male_marten.move_one_patch
              male_marten.patch.should == @desired_patch
            end
          end
        end
        context "selects a suitable tile from neighborhood" do
        end

        context "he backtracks" do

        end
      end

      describe "hunting" do
        it "has a chance of detecting and killing voles"
      end

      describe "being eaten" do
        it "has higher probability of survival on suitable tile"
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
