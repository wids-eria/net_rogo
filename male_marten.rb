require File.dirname(__FILE__) + '/marten'
require 'logger'

$log = Logger.new("marten_events.log")

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
      $log.info "#{self.id} died of old age"
      die
    end
  end


  def not_taken_by_other_marten? target
    target.marten.nil? || target.marten == self
  end


  def leave_scent_mark
    self.patch.marten = self
    self.patch.marten_scent_age = 0
  end


  # sex-specific sub-routines that feed into move_one_patch function 
  
  def face_random_direction
    # different turn methods

    # random
    turn rand(361).degrees

    #  correlated +
    #  turn self.normal_dist 0 self.turn_sd

    # correlated -
    #  turn self.normal_dist 180 self.turn_sd
  end


  def patch_desirable?(patch)
    not_taken_by_other_marten?(patch) && habitat_suitability_for(patch) == 1
  end

end
