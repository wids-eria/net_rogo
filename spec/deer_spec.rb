require File.dirname(__FILE__) + '/../male_deer'

describe MaleDeer do
  let!(:world) { World.new width: 300, height: 300 }
  let(:deers) { MaleDeer.spawn_population world, 10 }
  let(:male_deer) { deers.first }

  before do
    male_deer.location = [1.5, 1.5]
  end

# describe and before executed immediately prior to each it (to set it up)

  it 'ticks' do
    male_deer.tick
  end

  it 'does 365 ticks' do
    male_deer
    365.times{ world.tick }
  end

  it 'dies' do
    puts 1000.times.collect{(365*male_deer.active_hours).times.select{ male_deer.die_from_mortality_trial? }.count}.mean
    #1000000000.times do
    #  raise 'whee' if male_deer.die_from_mortality_trial?
    #end
  end

  it 'counts the number of agents around it'
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
