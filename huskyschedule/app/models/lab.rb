class Lab < ActiveRecord::Base
  
  belongs_to :teacher
  belongs_to :course, :class_name => "Course", :foreign_key => "parent_id"
  belongs_to :building
  
  Lab.partial_updates = false
  serialize :rendezvous
  
  def get_all_times
    ret = []
    if(rendezvous!=nil)
      for rende in self.rendezvous
        ret += rende.times
      end
    end
    return ret
  end
  
  def hours
    ret = 0.0;
    if(rendezvous!=nil)
      for rende in rendezvous
        ret = ret + rende.total_hours
      end
    end
    return ret
  end
  
  def self.find_by_building_quarter_year_day(building_id, quarter_id, year, day, overall_times)
    labs = Lab.find(:all, :conditions => "buildings LIKE '%#{building_id}%'")
    labs.delete_if{|lab| 
      !(lab.course.quarter_id==quarter_id && 
        lab.course.year==year && 
        Rendezvous.relevant_rendezvous(lab.rendezvous, building_id, day, overall_times)
       ) 
    }
    return labs
  end
  
end