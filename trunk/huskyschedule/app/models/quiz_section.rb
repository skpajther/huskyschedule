class QuizSection < ActiveRecord::Base
  
  belongs_to :teacher
  belongs_to :course, :class_name => "Course", :foreign_key => "parent_id"
  belongs_to :building
  
  QuizSection.partial_updates = false
  serialize :rendezvous
  
  def self.find_by_building_quarter_year_day(building_id, quarter_id, year, day, overall_times)
    quiz_sections = QuizSection.find_by_sql("SELECT * FROM quiz_sections WHERE buildings LIKE '%#{building_id}%'")
    quiz_sections.delete_if{|quiz_section| 
      !(quiz_section.course.quarter_id==quarter_id && 
        quiz_section.course.year==year && 
        Rendezvous.relevant_rendezvous(quiz_section.rendezvous, building_id, day, overall_times)
       ) 
    }
    return quiz_sections
  end

end