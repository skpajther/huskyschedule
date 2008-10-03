class BuildingsController < ApplicationController
  def map
    @buildings = Building.find(:all, :order => :name)
    @searching = false
    @selected
      #$query = mysql_query("SELECT name,abbrev FROM hs_campus_buildings WHERE abbrev LIKE '%$text%' OR name LIKE '%$text%' ORDER BY abbrev",$connection);
    
  end

  def index
  end

end
