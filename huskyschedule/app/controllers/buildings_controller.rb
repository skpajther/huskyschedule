class BuildingsController < ApplicationController
  def map
    @buildings = Building.find(:all, :order => :name)
    if(params[:search_text] != nil)
      @searching = true
      @search_results = Building.find_by_sql(
          "SELECT * 
           FROM buildings 
           WHERE abbrev LIKE '%#{params[:search_text]}%' 
           OR name LIKE '%#{params[:search_text]}%' 
           ORDER BY abbrev"
      )
    else
      @searching = false
    end
    @selected = params[:selected]
  end

  def index
  end

end
