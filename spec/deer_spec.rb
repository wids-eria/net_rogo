require File.dirname(__FILE__) + '/../deer'

describe Deer do
  let!(:world) { World.new width: 300, height: 300 }
  let(:deers) { Deer.spawn_population world, 10 }
  let(:deer) { deers.first }

  before do
    deer.location = [1.5, 1.5]
  end

  it 'ticks' do
    deer.tick
  end

  it 'does 100 ticks' do
    deer
    100.times{ world.tick }
  end

end
