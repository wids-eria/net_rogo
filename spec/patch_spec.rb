require File.dirname(__FILE__) + '/../patch'

describe Patch do
  let(:patch) { Patch.new }
  before do
    patch.x = 1
    patch.y = 2
  end
  it 'returns center_x from its coordinates' do
    patch.center_x.should == 1.5
  end

  it 'returns center_y from its coordinates' do
    patch.center_y.should == 2.5
  end

  it 'grode some voles in tha summer' do
    patch.vole_population = 0
    patch.grow_voles
    patch.vole_population.should == 0

    patch.vole_population = patch.max_vole_pop * 0.5
    patch.grow_voles
    patch.vole_population.should be_within(0.00001).of(6.961954)

    patch.vole_population = patch.max_vole_pop * 0.75
    patch.grow_voles
    patch.vole_population.should  be_within(0.00001).of(10.4339655)

    patch.vole_population = patch.max_vole_pop
    patch.grow_voles
    patch.vole_population.should == patch.max_vole_pop
  end

  it 'groded some voles in tha cold'
end
