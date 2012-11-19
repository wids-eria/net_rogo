module DBBindings
  class Agent < ActiveRecord::Base
    belongs_to :world
    self.table_name = "agents"
  end

  class Marten < Agent
  end
  
  class MaleMarten < Marten
  end
      
  class FemaleMarten < Marten  
  end    
end
