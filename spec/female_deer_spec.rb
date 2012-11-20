require File.dirname(__FILE__) + '/../female_deer'

describe FemaleDeer do
  let!(:world) { World.new width: 3, height: 3 }
  let!(:female_deer) { FemaleDeer.spawn_population(world, 1).first }

  it 'starts off with certain parameters' do
    female_deer.reproductive_stage.should == :anestrus
    female_deer.estrous_cycle_length.should >= 3
    female_deer.reproductive_clock.should == 0
  end

  it 'sets estrous clock and stage if older than 365 days'

  # FIXME would be nice as plugin-a-weeks state_machine
  it 'has reproductive stages' do
    female_deer.reproductive_stage = nil

    female_deer.set_anestrus
    female_deer.anestrus?.should == true

    female_deer.impregnate
    female_deer.impregnated?.should == true

    female_deer.set_di_metestrus
    female_deer.di_metestrus?.should == true

    female_deer.set_estrus
    female_deer.estrus?.should == true

    female_deer.set_gestation
    female_deer.gestation?.should == true

    female_deer.set_parturition
    female_deer.parturition?.should == true

    female_deer.set_lactation
    female_deer.lactation?.should == true

    female_deer.set_lactation
    female_deer.lactation?.should == true
  end

  it 'gives birth' do
    previous_count = world.deers.count

    female_deer.give_birth
    world.deers.count.should > previous_count

  end
end
