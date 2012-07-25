require File.dirname(__FILE__) + '/marten'
class FemaleMarten < Marten

  def tick
    raise 'spawn me' if spawned?
    go
  end


  def go
    actual_distance = 0
    forage
    die_if_starved
    metabolize
    attempt_to_reproduce
    self.age += 1
    if age > (18 * 365)
      print 'wat'
      die
    end
  end


  def stay_probability
    (1 - BASE_PATCH_ENTRANCE_PROBABILITY) * (self.energy / MAX_ENERGY)
  end


  # sex-specific sub-routines that feed into move_one_patch function 
  def move_one_patch
    target = patch_ahead 1

    # faced patch desirable
    # faced patch force move
    #
    # find desirable neighboring patch
    # no desirable, about face

    if passable?(target)
      if patch_desirable?(target)
        walk_forward 1
        self.random_walk_suitable_count += 1
      elsif should_leave?
        walk_forward 1
        self.random_walk_unsuitable_count += 1
      else
        select_forage_patch_and_move
      end
    else
      select_forage_patch_and_move
    end
  end


  def face_random_direction
    # different turn methods

    # random
    # turn rand(361).degrees

    #  correlated +
    #  turn self.normal_dist 0 self.turn_sd

    # correlated -
      turn self.normal_dist 180 self.turn_sd
  end


  def desirable_patches
    #neighborhood_in_radius(1).select{|patch| patch_desirable? patch }
    neighborhood.select{|patch| patch_desirable? patch }
  end

  def patch_desirable?(patch)
    habitat_suitability_for(patch) == 1
  end

  def self.can_spawn_on?(patch)
    self.passable?(patch) && self.habitat_suitability_for(patch) == 1
  end

  def attempt_to_reproduce
   if growing_season? 
     if immature_reproductive_age?
       if rand > 0.5 
         (1..5).to_a.sample.times{reproduce}
       end
     end
     if mature_reproductive_range?
       if rand > 0.2 
         (1..5).to_a.sample.times{reproduce}
       end
     end
   end
  end

  def reproduce
    if rand > 0.5
      FemaleMarten.spawn_at(self.world, self.x, self.y)
    else 
      MaleMarten.spawn_at(self.world, self.x, self.y)
    end
  end

  def immature_reproductive_age?
   365..730.include? age 
  end

  def mature_reproductive_range?
   age > 731
  end

end

