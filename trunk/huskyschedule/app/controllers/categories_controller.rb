class CategoriesController < ApplicationController
  
  def index
    if(params[:id]!=nil)
      @category = Category.find(params[:id])
      curr = @category
      @familypath = []
      @familypath.push(curr)
      
      while curr.parent!=nil
        @familypath.push(curr.parent)
        curr = curr.parent
      end
      
      if(@category.children.size>0)
        query = "courses.parent_id IN (#{@category.children.map{|child| child.id }.inspect.delete!('[]')})"
        if(params[:limitors]!=nil)
          if(params[:limitors]["custom"]!=nil && params[:limitors]["custom"].include?(query))
            #do nothing the query is already here
          else
            if(params[:limitors]["custom"]==nil)
              params[:limitors]["custom"] = [query]
            else
              params[:limitors]["custom"].push(query)
            end
          end
        else
          params[:limitors] = {:custom=>[query]}
        end
      else
        if(params[:limitors]!=nil)
          params[:limitors]["category_id"] = @category.id
        else
          params[:limitors] = {"category_id" => @category.id}
        end
      end
      
      if(!params.key?(:page) || params[:page]=="")
        params[:page] = 1
      end
      @courses = Course.find_or_count_by_limitors(params)
      @limitors = params[:limitors]
      #@test_schedule = [[Time.parse("September 22, 2008 8:00"), Time.parse("September 22, 2008 11:00")],[Time.parse("September 22, 2008 11:00"), Time.parse("September 22, 2008 16:00")],[Time.parse("September 26, 2008 13:00"), Time.parse("September 26, 2008 18:00")]]
    end
  end
  
end
