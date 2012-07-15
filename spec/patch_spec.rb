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
end
