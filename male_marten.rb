require File.dirname(__FILE__) + '/marten'
class MaleMarten < Marten

  def tick
    raise 'spawn me' if spawned?
    go
  end


  def go
    actual_distance = 0
    forage
    die_if_starved
    metabolize
    self.age += 1
    if age > (18 * 365)
      print 'wat'
      die
    end
  end


  def stay_probability
    (1 - BASE_PATCH_ENTRANCE_PROBABILITY) * (self.energy / MAX_ENERGY)
  end


  def should_leave?
    stay_probability < rand
  end

  def not_taken_by_other_marten? target
    target.marten_id.nil? || target.marten_id == self.id
  end


  def leave_scent_mark
    self.patch.marten_id = self
    self.patch.marten_scent_age = 0
  end


  # sex-specific sub-routines that feed into move_one_patch function 
  def move_one_patch
    target = patch_ahead 1

    if passable?(target) && (patch_desirable?(target) || should_leave?)
      walk_forward 1
    else
      select_forage_patch_and_move
    end
  end


  def face_random_direction
    # different turn methods

    # random
    turn rand(361).degrees

    #  correlated +
    #  turn self.normal_dist 0 self.turn_sd

    # correlated -
    #  turn self.normal_dist 180 self.turn_sd
  end


  def desirable_patches
    #neighborhood_in_radius(1).select{|patch| patch_desirable? patch }
    neighborhood.select{|patch| patch_desirable? patch }
  end

  def patch_desirable?(patch)
    not_taken_by_other_marten?(patch) && habitat_suitability_for(patch) == 1
  end

  def self.can_spawn_on?(patch)
    self.passable?(patch) && self.habitat_suitability_for(patch) == 1
  end
end
