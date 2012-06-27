require File.dirname(__FILE__) + '/../male_marten'

describe MaleMarten do
 let(:male_marten) {MaleMarten.new} 
 it 'ticks' do
   male_marten.tick
  end
end
