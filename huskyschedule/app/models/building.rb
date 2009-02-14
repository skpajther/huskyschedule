class Building < ActiveRecord::Base
  
  has_many :courses
  
  #Building constants
  BUILDING_NOTFOUND = -1 #Regex failed
 
  def self.get_building_id(abbrev)
    building = Building.find_by_abbrev(abbrev)
    if(building.nil?) #building not already in there
      building = Building.create(:abbrev=>abbrev)
    end
    return building.id
  end
  
  
  
end
