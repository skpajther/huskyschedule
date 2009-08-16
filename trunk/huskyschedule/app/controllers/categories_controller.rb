class CategoriesController < ApplicationController
  
  def index
    if(params[:id]!=nil)
      @category = Category.find(params[:id])
    elsif(session[:last_category]!=nil)
      @category = Category.find(session[:last_category])
    else
      @category = Category.find(Category::HOME_ID)
    end
    session[:last_category] = @category.id
    
    @familypath = @category.parent_path
    
    if(params[:limitors]==nil && session[:category_limitors]!=nil)
      params[:limitors] = session[:category_limitors]
    end
        
    if(params[:no_child_search_needed]==nil || params[:no_child_search_needed]!="true")
      query = @category.all_children_query_string
      help.add_to_limitors(params, "parent_id", query, {:do_not_add_to_order=>true})
    end
    
    session[:category_limitors] = params[:limitors]
      
    if(!params.key?(:page) || params[:page]=="")
      if(session[:category_page]!=nil)
        params[:page] = session[:category_page]
      else
        params[:page] = 1
      end
    end
    session[:category_page] = params[:page]
    
    if(params[:per_page]==nil || params[:par_page]=="")
      if(session[:category_per_page]!=nil)
        params[:per_page] = session[:category_per_page]
      else
        params[:per_page] = 20
      end
    end
    session[:category_per_page] = params[:per_page]
    
    @courses = Course.find_or_count_by_limitors(params)
    total_pages = WillPaginate::ViewHelpers.total_pages_for_collection(@courses)
    if(params[:page].to_i>1 && params[:page].to_i>total_pages)
      params[:page] = total_pages
      @courses = Course.find_or_count_by_limitors(params)
    end
    @limitors = params[:limitors]
    @params = params
  end
  
end
