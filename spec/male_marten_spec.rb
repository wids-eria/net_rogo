require File.dirname(__FILE__) + '/../male_marten'

describe MaleMarten do
  let(:male_marten) {MaleMarten.new} 
  it 'ticks' do
   male_marten.tick
  end

  describe "#forage_distance" do
    it "is 1000 meters per hour" do
      male_marten.forage_distance.should be_within(0.001).of(15.7183)
    end
  end

  describe "daily cycle" do
    it "has 8 active hours in winter" do
      male_marten.stub :growing_season? => false
      male_marten.active_hours.should == 8
    end

    it "has 12 active hours in the growing season" do
      male_marten.stub :growing_season? => true
      male_marten.active_hours.should == 12
    end

    describe "hourly routine" do
      it "forages until its full"
      it "forages until it cant forage no mo"

      describe "moving" do
        context "random facing" do
          it "does a walk if suitable and unowned"
          it "has probability to walk even if unsuitable"
          it "has probability to walk even if owned"
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
end
