require File.dirname(__FILE__) + '/../male_deer'

describe MaleDeer do
  let!(:world) { World.new width: 300, height: 300 }
  let(:deers) { MaleDeer.spawn_population world, 10 }
  let(:male_deer) { deers.first }

  before do
    male_deer.location = [1.5, 1.5]
  end

  it 'ticks' do
    male_deer.tick
  end

  it 'does 365 ticks' do
    male_deer
    365.times{ world.tick }
  end

#  describe "#forage_distance" do
#    it "is 1000 meters per hour" do
#      male_marten.forage_distance.should be_within(0.001).of(15.7183)
#    end
#  end

end
