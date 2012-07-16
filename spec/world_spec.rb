require File.dirname(__FILE__) + '/../world'
require File.dirname(__FILE__) + '/../patch'

describe World do
  let!(:world) { World.new width: 30, height: 30 }
  it 'returns the patch at x 1, y 5' do
    patch = world.patch(1,5)
    patch.x.should == 1
    patch.y.should == 5
  end

  it 'returns the patch at x 5, y 1' do
    patch = world.patch(5,1)
    patch.x.should == 5
    patch.y.should == 1
  end

  it 'returns the patch at x 5.5, y 1.1' do
    patch = world.patch(5.5,1.1)
    patch.x.should == 5
    patch.y.should == 1
  end

  it 'returns the patch at x 0, y 5' do
    patch = world.patch(0,5)
    patch.x.should == 0
    patch.y.should == 5
  end

  it 'returns the patch at x 5, y 0' do
    patch = world.patch(5,0)
    patch.x.should == 5
    patch.y.should == 0
  end

  it 'contains unique patches for every x,y' do
    world.all_patches.size.should == world.all_patches.uniq.size
  end
end
