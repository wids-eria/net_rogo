require File.dirname(__FILE__) + '/../number'

describe Numeric do
  it "converts to radians" do
    180.in_radians.should == Math::PI
  end
end
