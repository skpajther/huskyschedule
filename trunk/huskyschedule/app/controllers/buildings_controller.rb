class BuildingsController < ApplicationController
  def map
     if(params[:id]!=nil)
       @show_building = Building.find(params[:id])
     end
     @buildings = Building.find_by_sql("SELECT * FROM buildings WHERE uw_lat != '' ORDER BY abbrev")
#    if(params[:search_text] != nil)
#      @searching = true
#      @search_results = Building.find_by_sql(
#          "SELECT * 
#           FROM buildings 
#           WHERE abbrev LIKE '%#{params[:search_text]}%' 
#           OR name LIKE '%#{params[:search_text]}%' 
#           ORDER BY abbrev"
#      )
#    else
#      @searching = false
#    end
#    @selected = params[:selected]
  end

  def index
  end
  
  def map_loader
    @xml = Builder::XmlMarkup.new
    @buildings = Building.find_by_sql("SELECT * FROM buildings WHERE lat != '' ORDER BY abbrev")
    @xml.buildings {
      for building in @buildings
        @xml.building(:name=>building.name, :abbrev=>building.abbrev, :lat=>building.lat, :lng=>building.lng, :uw_lat=>building.uw_lat, :uw_lng=>building.uw_lng)
      end
    }
    respond_to do|format|
      format.xml{render :xml => @xml }
    end
  end

end
