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
      
      if(params[:no_child_search_needed]==nil || params[:no_child_search_needed]!="true")
        query = @category.all_children_query_string
        help.add_to_limitors(params, "parent_id", query, {:do_not_add_to_order=>true})
      end
       
      
      if(!params.key?(:page) || params[:page]=="")
        params[:page] = 1
      end
      puts("here1")
      @courses = Course.find_or_count_by_limitors(params)
      puts("here2")
      @limitors = params[:limitors]
      @params = params
      #@test_schedule = [[Time.parse("September 22, 2008 8:00"), Time.parse("September 22, 2008 11:00")],[Time.parse("September 22, 2008 11:00"), Time.parse("September 22, 2008 16:00")],[Time.parse("September 26, 2008 13:00"), Time.parse("September 26, 2008 18:00")]]
    end
  end
  
end
