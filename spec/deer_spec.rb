require File.dirname(__FILE__) + '/../male_deer'

describe MaleDeer do
  let!(:world) { World.new width: 300, height: 300 }
  let!(:deers) { MaleDeer.spawn_population world, 2 }
  let(:male_deer) { deers.first }
  let(:male_deer_2) { deers[1] }

  before do
    male_deer.location = [1.5, 1.5]
    male_deer_2.location = [1.1, 1.1]
  end

# describe and before executed immediately prior to each it (to set it up)

  it 'ticks' do
    male_deer.tick
  end


  it 'ticks2' do
    male_deer_2.tick
  end


  it 'does 365 ticks' do
    365.times{ world.tick }
  end


  it 'dies' do
    puts 1000.times.collect{(365*male_deer.active_hours).times.select{ male_deer.die_from_mortality_trial? }.count}.mean
    #1000000000.times do
    #  raise 'whee' if male_deer.die_from_mortality_trial?
    #end
  end

  
  it 'checks agents on patch' do
    puts male_deer.x
    puts male_deer.y
    puts male_deer.patch
    puts world.patch(1,1)
    male_deer.patch.agents.count.should == 2
    male_deer.patch.agents.should == [male_deer, male_deer_2]
  end


  it 'counts the number of agents around it' do
    male_deer.agents_in_radius(1).count.should == 1
    male_deer.agents_in_radius(1).should == [male_deer_2]
  end


  it 'moves'
  it 'chases ladies during rut'
  it 'picks a destination after evaluating the neighborhood'
  # base decision on percieved food content of patch
  it 'seeks thermal cover in winter'


  # Mabes
  it 'moves to cover at the end of the day'

#  describe "#forage_distance" do
#    it "is 1000 meters per hour" do
#      male_marten.forage_distance.should be_within(0.001).of(15.7183)
#    end
#  end

end
