require File.dirname(__FILE__) + '/../female_deer'

describe FemaleDeer do
  let!(:world) { World.new width: 3, height: 3 }
  let!(:female_deer) { FemaleDeer.spawn_population(world, 1).first }

  it 'starts off with certain parameters' do
    female_deer.reproductive_stage.should == :anestrous
    female_deer.estrous_cycle_length.should >= 3
    female_deer.reproductive_clock.should == 0
  end

  it 'sets estrous clock and stage if older than 365 days'
end
