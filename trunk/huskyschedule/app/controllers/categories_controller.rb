class CategoriesController < ApplicationController
  
  def index
    if(params[:id]!=nil)
      @category = Category.find(params[:id])
    else
      @category = Category.find(Category::HOME_ID)
    end
      @familypath = @category.parent_path
      
      
      if(params[:no_child_search_needed]==nil || params[:no_child_search_needed]!="true")
        query = @category.all_children_query_string
        help.add_to_limitors(params, "parent_id", query, {:do_not_add_to_order=>true})
      end
      
    
    
    if(!params.key?(:page) || params[:page]=="")
      params[:page] = 1
    end
    @courses = Course.find_or_count_by_limitors(params)
    @limitors = params[:limitors]
    @params = params
  end
  
end
