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
  
  def self.search(query)
    return Building.find_by_sql("SELECT * FROM buildings WHERE abbrev LIKE '%#{query}%' OR name LIKE '%#{query}%' ORDER BY abbrev")
  end
  
end
