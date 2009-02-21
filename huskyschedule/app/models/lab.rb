class Lab < ActiveRecord::Base
  
  belongs_to :teacher
  belongs_to :course, :class_name => "Course", :foreign_key => "parent_id"
  belongs_to :building
  
  Lab.partial_updates = false
  serialize :rendezvous
  
  def self.find_by_building_quarter_year_day(building_id, quarter_id, year, day, overall_times)
    labs = Lab.find_by_sql("SELECT * FROM labs WHERE buildings LIKE '%#{building_id}%'")
    labs.delete_if{|lab| 
      !(lab.course.quarter_id==quarter_id && 
        lab.course.year==year && 
        Rendezvous.relevant_rendezvous(lab.rendezvous, building_id, day, overall_times)
       ) 
    }
    return labs
  end
  
end