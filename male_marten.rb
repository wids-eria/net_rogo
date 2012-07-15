require File.dirname(__FILE__) + '/marten'
class MaleMarten < Marten

  def tick
    go
  end


  def go
    actual_distance = 0
    forage
    die_if_starved
    metabolize
    self.age += 1
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


  # sex-specific sub-routines that feed into move_one_patch function 
  def move_one_patch
    target = patch_ahead 1

    if patch_desirable? target
      walk_forward 1
    else
      force_enter_target_or_random_suitable_or_aboutface
    end
  end

  # TODO reduce walk forward to 1?
  # select forage patch unless desireable or should go..
  # then walk forward 1


  def force_enter_target_or_random_suitable_or_aboutface
    if should_leave?
      walk_forward 1
    else
      select_forage_patch # face random suitable or about face
      walk_forward 1
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


  def desireable_patches
    patches_in_radius(1).select{|patch| patch_desirable? patch }
  end

  def patch_desirable?(patch)
    not_taken_by_other_marten?(patch) && habitat_suitability_for(patch) == 1
  end
end
