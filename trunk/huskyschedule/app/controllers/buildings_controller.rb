class BuildingsController < ApplicationController
  def map
     if(params[:id]!=nil)
       @show_building = Building.find(params[:id])
     end
     @buildings = Building.find_by_sql("SELECT * FROM buildings WHERE uw_lat != '' ORDER BY abbrev")
  end
  
  #view constants
  VIEW_ALL = 0
  VIEW_LECTURES = 1
  VIEW_QUIZSECTIONS = 2
  VIEW_LABS = 3
  VIEW_POSSIBILITIES = 4

  def index
    @building = nil
    if(!params[:id].nil?)
      @building = Building.find(params[:id])
      if(!(@building.nil?))
        @distinct_quarters = Quarter.find_distinct_quarters #this is in descending order from most recently parsed to least
        
        #get year
        year = nil
        if(!params[:year].nil?)
          year = params[:year].to_i 
        else
          year = @distinct_quarters[0].year #most recent year
        end
        
        #get quarter_id
        quarter_id = nil
        if(!params[:quarter_id].nil?)
          quarter_id = params[:quarter_id].to_i
        else
          quarter_id = @distinct_quarters[0].quarter_id #most recent quarter
        end
        
        #find correct DistinctQuarter object for derived quarter_id, year
        selected_quarter = Quarter.find_correct_quarter(@distinct_quarters, quarter_id, year)
        selected_quarter.active = true #all others are false
        
        #get day (integer value)
        @day = nil
        if(!params[:day].nil?)
          @day = params[:day].to_i
          if(!(@day>=Quarter::MONDAY.wday && @day<=Quarter::FRIDAY.wday))
            @day = Quarter::MONDAY.wday #default to Monday
          end
        else
          @day = Quarter::MONDAY.wday #default to Monday
        end
        
        #get view
        @view = nil
        if(!params[:view].nil?)
          @view = params[:view].to_i
          if(@view >= VIEW_POSSIBILITIES || @view < 0)
            @view = VIEW_ALL
          end
        else
          @view = VIEW_ALL
        end
        
        #now we have quarter, year, day
        courses = []
        quiz_sections = []
        labs = []
        @overall_times = []
        courses = Course.find_by_building_quarter_year_day(@building.id, selected_quarter.quarter_id, selected_quarter.year, @day, ((@view == VIEW_ALL || @view == VIEW_LECTURES)? @overall_times : []))
        quiz_sections = QuizSection.find_by_building_quarter_year_day(@building.id, selected_quarter.quarter_id, selected_quarter.year, @day, ((@view == VIEW_ALL || @view == VIEW_QUIZSECTIONS)? @overall_times : []))
        labs = Lab.find_by_building_quarter_year_day(@building.id, selected_quarter.quarter_id, selected_quarter.year, @day, ((@view == VIEW_ALL || @view == VIEW_LABS)? @overall_times : []))
        @overall_times.sort!
        @results = "Found #{courses.length.to_s} courses, #{quiz_sections.length.to_s} quiz sections, and #{labs.length.to_s} lab sections."
        @distinct_quarter_data = DistinctQuarterData.new(:distinct_quarter=>selected_quarter, :courses=>courses, :quiz_sections=>quiz_sections, :labs=>labs)
        @searched_on = "I searched for courses in #{Quarter.quarter_disp_name(quarter_id)}#{year} on #{@day} in #{Building.find(@building.id).name}"
      end  
    end
  end
  
  def map_loader
    @xml = Builder::XmlMarkup.new
    @buildings = []
    if(!params[:id].nil?) #for loading info about one building only (used in minimap)
      @buildings = @buildings.push(Building.find(params[:id]))
    else
      @buildings = Building.find_by_sql("SELECT * FROM buildings WHERE lat != '' ORDER BY abbrev")
    end
    @xml.buildings {
      for building in @buildings
        @xml.building(:name=>building.name, :abbrev=>building.abbrev, :lat=>building.lat, :lng=>building.lng, :uw_lat=>building.uw_lat, :uw_lng=>building.uw_lng, :id=>building.id)
      end
    }
    respond_to do|format|
      format.xml{render :xml => @xml }
    end
  end
  
  def search_results
    @buildings = Building.search(params[:search_text])
  end

end