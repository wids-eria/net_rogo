require File.dirname(__FILE__) + '/../female_marten'

describe FemaleMarten do
  let!(:world) { World.new width: 300, height: 300 }
  let(:martens) { FemaleMarten.spawn_population world, 10 }
  let(:female_marten) { martens.first }

  before do
    female_marten.location = [1.5, 1.5]
  end


  it 'ticks' do
    female_marten.tick
  end

  it 'reproduces' do
    10.times{ female_marten.reproduce }
  end

  it 'does 100 ticks' do
    female_marten
    100.times{ world.tick }
  end
end

