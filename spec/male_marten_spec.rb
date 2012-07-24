require File.dirname(__FILE__) + '/../male_marten'

describe MaleMarten do
  let!(:world) { World.new width: 300, height: 300 }
  let(:martens) { MaleMarten.spawn_population world, 10 }
  let(:male_marten) { martens.first }

  before do
    male_marten.location = [1.5, 1.5]
  end

  it 'has mortality' do
    puts 100.times.collect{(365*male_marten.active_hours*200).times.select{ male_marten.die_from_fatal_blows? }.count}.mean
  end

  it 'ticks' do
    male_marten.tick
  end

  it 'does 1000 ticks' do
    male_marten
    1000.times{ world.tick }
  end

  it 'ticks with a randomized world'
  it 'ticks with a half n half world'
  it 'can only spawn at a desirable location'

  describe '#location' do
    it 'returns x and y' do
      male_marten.x = 5.0
      male_marten.y = 6.0
      male_marten.location.should == [5.0, 6.0]
    end
  end

  describe "#forage_distance" do
    it "is 1000 meters per hour" do
      male_marten.forage_distance.should be_within(0.001).of(15.7183)
    end
  end

  describe '#stay_probability' do
    let(:max_energy) { MaleMarten::MAX_ENERGY }
    let(:stay_probability) { 0.97 }
    it 'is 97% when full' do
      male_marten.energy = max_energy
      male_marten.stay_probability.should == stay_probability
    end

    it 'is 48.5% when half energy' do
      male_marten.energy = max_energy * 0.5
      male_marten.stay_probability.should == stay_probability * 0.5
    end

    it 'is 0% when starving' do
      male_marten.energy = 0
      male_marten.stay_probability.should == 0.0
    end

    it 'is over 97% when over stuffed' do
      male_marten.energy = max_energy + 1
      male_marten.stay_probability.should > stay_probability
    end

    it 'is below 0% when in the red' do
      male_marten.energy = -1.0
      male_marten.stay_probability.should < 0.0
    end
  end

  describe '#face_patch' do
    it 'faces lower left patch' do
      male_marten.face_patch world.patch(0,0)
      male_marten.heading.should == 225.0
    end

    it 'faces lower middle patch' do
      male_marten.face_patch world.patch(1,0)
      male_marten.heading.should == 270.0
    end

    it 'faces upper left patch' do
      male_marten.face_patch world.patch(0,2)
      male_marten.heading.should == 135.0
    end

    it 'faces middle left patch' do
      male_marten.face_patch world.patch(0,1)
      male_marten.heading.should == 180.0
    end

    it 'faces upper right patch' do
      male_marten.face_patch world.patch(2,2)
      male_marten.heading.should == 45.0
    end
  end

  describe '#habitat_suitability_for' do
    let(:happy_little_patch) { Patch.new }

    it 'returns the suitability for a happy patch' do
      happy_little_patch.land_cover_class = :deciduous
      male_marten.habitat_suitability_for(happy_little_patch).should == 1
    end

    it 'returns the suitability for an unhappy patch' do
      happy_little_patch.land_cover_class = :barren
      male_marten.habitat_suitability_for(happy_little_patch).should == 0
    end
  end

  describe '#patches_in_radius' do
    it 'returns neighborhood of 1 from center of patch' do
      male_marten.location = [1.5, 1.5]
      male_marten.neighborhood_in_radius(1).collect(&:location).to_set.should == [[0,2],[1,2],[2,2],
                                                                             [0,1],      [2,1],
                                                                             [0,0],[1,0],[2,0]].to_set
    end

    it 'returns neighborhood of 1 from corner of patch' do
      male_marten.location = [1.9, 1.9]
      male_marten.neighborhood_in_radius(1).collect(&:location).to_set.should == [[0,2],[1,2],[2,2],
                                                                             [0,1],      [2,1],
                                                                                   [1,0],[2,0]].to_set
    end

    it 'returns neighborhood of 1 from corner of world' do
      male_marten.location = [0.1, 0.1]
      male_marten.neighborhood_in_radius(1).collect(&:location).to_set.should == [
                                                                             [0,1],
                                                                                   [1,0]      ].to_set
    end

    it 'returns neighborhood of 1 from corner of world' do
      male_marten.location = [0.0, 0.0]
      male_marten.neighborhood_in_radius(1).collect(&:location).to_set.should == [

                                                                                              ].to_set
    end
  end

  describe "daily cycle" do
    it "has 8 active hours in winter" do
      male_marten.stubs :growing_season? => false
      male_marten.active_hours.should == 8
    end

    it "has 12 active hours in the growing season" do
      male_marten.stubs :growing_season? => true
      male_marten.active_hours.should == 12
    end

    it "forages once for each active hour" do
      male_marten.stubs :active_hours => 5
      male_marten.expects(:hourly_routine).times(5)
      male_marten.forage
    end

    describe "hourly routine" do
      describe "moving" do
        context "when facing a suitable patch" do
          let (:desired_patch) { world.patch(0, 1) }

          before do
            male_marten.heading = 180.degrees
            male_marten.location = [1.5, 1.5]
            male_marten.energy = 1000000
            desired_patch.land_cover_class = :deciduous
            desired_patch.marten = nil
          end

          context "that is unscented" do
            it "moves one unit of distance and lands on the patch" do
              male_marten.move_one_patch
              male_marten.patch.should == desired_patch
            end
          end
        end

        context 'when selecting a forage patch' do
          before do
            male_marten.location = [1.5, 1.5]
            male_marten.previous_location = [0.5, 0.5]
            male_marten.heading = 45.degrees
          end

          it 'backtracks if no suitable patches' do
            male_marten.stubs desireable_patches: []
            male_marten.select_forage_patch_and_move
            male_marten.heading.should == 225.degrees
          end

          it 'goes to the tile with the largest vole population' do
            patch1 = world.patch(2,2)
            patch1.max_vole_pop = 50.0

            patch2 = world.patch(2,0)
            patch2.max_vole_pop = 20.0

            male_marten.stubs desireable_patches: [patch2, patch1]

            male_marten.select_forage_patch_and_move
            male_marten.heading.should == 45.degrees
          end

          it 'does nothing if no suitable tiles and previous location is current location' do
            male_marten.stubs desireable_patches: []
            male_marten.location = male_marten.previous_location = [1.5, 1.5]

            male_marten.select_forage_patch_and_move
          end
        end
      end

      describe "hunting" do
        it "has a chance of detecting and killing voles"
      end

      describe "being eaten" do
        it "has higher probability of survival on suitable patch"
      end
    end
  end

  describe "starvation" do
    it "starves if he has no energy"
  end

  describe "metabolizing" do
    it "uses more energy in the growing season"
  end



  describe "stuffy stuff" do
    it "keeps heading within 2PI or 360"
    it "increases heading if turning right"
    it 'it handled unpassible (or non existant) patches'
  end

  describe 'random trial' do
    it 'runs random ticks a bunch' do
      raise 'make me work'
    end
  end
end
