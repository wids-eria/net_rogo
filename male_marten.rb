require File.dirname(__FILE__) + '/marten'
class MaleMarten < Marten

  def tick
    go
  end

  TURN_SD = 90

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


  # sex-specific sub-routines that feed into move_one_patch function 
  def move_one_patch
    target = patch_ahead 1
    neighborhood = nearby_tiles 1

    # check scent of patch ahead to see if it's someone else's
    if (target.marten_id.nil? or target.marten_id == self.id)
      if habitat_suitability_for (target) == 1
        walk_forward 1
      else
        if should_leave?
          walk_forward 1
        else
          select_forage_patch
          walk_forward 1
        end
      end
    else
      if should_leave?
        walk_forward 1
      end
    end
  end


  def face_random_direction
    # different turn methods
    # random
    turn rand(361)
    #  correlated +
    #  turn self.normal_dist 0 self.turn_sd
    # correlated -
    #  turn self.normal_dist 180 self.turn_sd
  end


  def set_neighborhood
    # determine surrounding tiles that are "suitable"
    neighborhood = nearby_tiles.select {tile.residue[:marten_id].nil? or tile.residue[:marten_id]==self.id}
    neighborhood = habitat_suitability_for (neighborhood) == 1 #TODO: have to check approach to selecting 'suitable' tiles in neighborhood
  end
end
