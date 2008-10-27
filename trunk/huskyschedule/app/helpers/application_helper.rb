# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
def mini_schedule(times, options={})
    by_hour = true
    start_hour = 7
    end_hour = 13
		reg = ":00"
		half = ":30"
		whole = by_hour
    schedule_st = ""
    if(options[:by_hour]!=nil)
      by_hour = options[:by_hour]
    end
    if(options[:start_hour]!=nil)
      start_hour = options[:start_hour]-1
    end
    if(options[:end_hour]!=nil)
      end_hour = options[:end_hour]
    end
    num = start_hour - ((by_hour)? 1 : 0.5)
    whole = (num%1!=0) || by_hour
    ((end_hour - start_hour)*2).to_i.times{ |i|
			tmp = half
			st = "<font size='1' face='Verdana'>&nbsp;</font>"
			if(whole)
				tmp = reg
				num = num+((by_hour)? 1 : 0.5)
				st = "<font size='1' face='Verdana'>#{(num-((num>12.5)? 12 : 0)).to_i}#{tmp}</font>"
			elsif(!by_hour)
			  num = num + 0.5
        st = "<font size='1' face='Verdana'>#{(num-0.5-((num>12.5)? 12 : 0)).to_i}#{tmp}</font>"
			end
			
			weekdata = getTableRow(num, times, ((by_hour)? 1 : 2))
			schedule_st = schedule_st+"<tr height='1'>
										           <td>#{st}</td>
										           #{weekdata}
		  							         </tr>";
			whole = !whole || by_hour;
		}
		result = "<table width='2' border='1' cellpadding='0' cellspacing='0'>
      					<tr>
                   <td bgcolor='#DED1ED' width='33.5' height='8'>&nbsp;</td>
                   <td bgcolor='#DED1ED' width='68.5'><font size='1' face='Verdana'>Mon</font></td>
                   <td bgcolor='#DED1ED' width='68.5'><font size='1' face='Verdana'>Tues</font></td>
                   <td bgcolor='#DED1ED' width='68.5'><font size='1' face='Verdana'>Wed</font></td>
                   <td bgcolor='#DED1ED' width='68.5'><font size='1' face='Verdana'>Thur</font></td>
                   <td bgcolor='#DED1ED' width='68.5'><font size='1' face='Verdana'>&nbsp;Fri&nbsp;</font></td>
                </tr>
      		      #{schedule_st}
      			   </table>
					This is where the time should be displayed";
		#if(options[:display_text_times])
		#  groups = []#[[[1,4],[time1,time2]], ]
		#  for course_time in times
		#    if(groups.each{|arr| arr[1].each{|ct| if(ct[0]==course_time[0]&&ct[1]==course_time[1]) }})
		#    groups.push([[course_time[0].wday],[course_time]])
		#  end
		#  result = result + ""
		#end 
		return result
  end
  
  def star_ratings(rating, size="32x32")
    if(rating==nil)
      rating = 0
    end
    result = ""
    rating = rating + 0.5
		rating.to_i.times{
			result = result + "<img src='/images/stars/star#{size}.png'/>"
		}
		(5-rating.to_i).times{
			result = result + "<img src='/images/stars/star_blank#{size}.png'/>"
		}
		return result
  end
  
  def bread_crumbs(category_or_course, include_self_link=false)
    @familypath = []
    @familypath.push(category_or_course)
    while( (category_or_course.is_a?(Course))? category_or_course.category!=nil : category_or_course.parent!=nil)
      if(category_or_course.is_a?(Course))
        @familypath.push(category_or_course.category)
        category_or_course = category_or_course.category
      else
        @familypath.push(category_or_course.parent)
        category_or_course = category_or_course.parent
      end
    end
    result = link_to "Home"
	  while (parent = @familypath.pop)!=nil
	    if(parent.is_a?(Course))
	      if(!@familypath.empty? || include_self_link)
	        result = result + " > " + link_to("SLN: #{parent.sln}", :controller=>"courses", :action=>"index", :id=>parent.id)
	      else
	        result = result + " > " + "SLN: #{parent.sln}"
	      end
	    else
	      if(!@familypath.empty? || include_self_link)
	        result = result + " > " + link_to(parent.name, :controller=>"categories", :action=>"index", :id=>parent.id)
	      else
	        result = result + " > " + parent.name
	      end
	    end
	  end
	  return result
  end
  
def review_percent_table(course, options={})
    reviews = CourseReview.find(:all, :conditions=>{:course_name=>course.name})
		total_reviews = course.total_ratings
				
  	all = [0,0,0,0,0]
    for course_review in reviews
      all[course_review.rating-1] = all[course_review.rating-1] + 1
    end
    bartable = "<table width='100%'>"
    5.times{|i|
          i = i + 1
					bartable << "<tr><td><table><tr><td>#{i}</td>"
					percent = (((all[i-1]*1.0)/((total_reviews<1)? 1 : total_reviews))*100).to_i
					if(percent>0)
						bartable << "<td class='barrow'><img src='/images/bars/bar_yellowLeft.gif'>"
					end
					(percent-8).times{
						bartable << "<img src='/images/bars/bar_yellowMid.gif'>"
					}
					if(percent>0)
						bartable << "<img src='/images/bars/bar_yellowRight.gif'></td>"
					else
						bartable << "<td class='barrow'></td>"
				  end
					bartable << "<td>#{percent}%</td></tr></table></td>"
				  if(options[:links]==true)
						bartable << "<td>"+link_to( all[i-1].to_s+" reviews", :controller=>"course_reviews", :action=>"index", :id=>course.id) +"</td>"
					end
          bartable << "</tr>"
		}
		bartable << "</table>"
		return bartable
  end
	
	def formatted_review(course_review)
      return " <tr>
        					<td height='1' style='border-bottom:solid 1px #999'><a class='smalltitle'><strong>#{course_review.review_name}</strong></a></td>
        			 </tr>
        			 <tr><td><table width='100%'><tr><td valign='top'>Reviewed By: #{(course_review.author!=nil)? course_review.author.login : 'Anonymous'} on #{course_review.created_at}</td><td align='right'>#{star_ratings(course_review.rating, "24x24")}</td></tr></table></tr>
        			 <tr><td><strong>Pros:</strong>&nbsp;#{course_review.pros}<td></tr>
        			 <tr><td><strong>Cons:</strong>&nbsp;#{course_review.cons}<td></tr>
        		   <tr><td><strong>Other Thoughts:</strong>&nbsp;#{course_review.other_thoughts}</td></tr>"
			 
	end
						
=begin  def class_review_summary(course)
        reviews = CourseReview.find(:all, :conditions=>{:course_name=>course.name})
				total_reviews = course.total_ratings
				
  				all = [0,0,0,0,0]
          for course_review in reviews
            all[course_review.rating-1] = all[course_review.rating-1] + 1
          end
          bartable = "<table>"
  				5.times{|i|
            i = i + 1
  					bartable << "<tr><td>#{i}</td><td class='barrow'>"
  					percent = (((all[i-1]*1.0)/((total_reviews<1)? 1 : total_reviews))*100).to_i
  					if(percent>0)
  						bartable << "<img src='/images/bars/bar_yellowLeft.gif'>"
  					end
  					(percent-8).times{
  						bartable << "<img src='/images/bars/bar_yellowMid.gif'>"
  					}
  					if(percent>0)
  						bartable << "<img src='/images/bars/bar_yellowRight.gif'>"
  				  end
  					bartable << "</td><td>#{percent}%</td></tr>"
  				}
  				bartable << "</table>"
  				example_review = reviews[0]
  				result = "<table width='100%'>
  								<tr>
  									<td height='1' style='border-bottom:solid 1px #999'><a class='smalltitle'><strong>Class Review Summary</strong></a>&nbsp;("+((total_reviews<1)? "" : "<a class='newlink' href='#'>read more reviews</a>,&nbsp;")+"<a class='newlink' href='#{url_for :controller=>'course_reviews', :action=>'new', :id=>course.id}'>"+((total_reviews<1)? "Be the first to write a review" : "write a review")+")</a></td>
  								</tr>
  								<tr>
  									<td>
  										<table width='100%'>
  											<tr>
  												<td rowspan='2'>#{bartable}</td>
  												<td height=1 align='right' valign='center'>Class Rating:</td>
  												<td width='160' align='right'>#{star_ratings(course.rating)}</td>
  											</tr>
  											<tr><td colspan='2' valign='top'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Total Reviews:#{total_reviews}</td></tr>
  										</table>
  									</td>
  								</tr>"
  								
          if(total_reviews > 0)				
            result << "<tr>
        							   <td height='1' style='border-bottom:solid 1px #999'><a class='smalltitle'><strong>#{example_review.review_name}</strong></a></td>
        							 </tr>
        							 <tr><td><table width='100%'><tr><td valign='top'>Reviewed By: #{example_review.author.login} on #{example_review.created_at}</td><td align='right'>#{star_ratings(example_review.rating, "24x24")}</td></tr></table></tr>
        							 <tr><td><strong>Pros:</strong>&nbsp;#{example_review.pros}<td></tr>
        							 <tr><td><strong>Cons:</strong>&nbsp;#{example_review.cons}<td></tr>
        							 <tr><td><strong>Other Thoughts:</strong>&nbsp;#{example_review.other_thoughts}</td></tr>
        						 </table>"
        	else
            result << "<tr>
        							   <td height='1' style='border-bottom:solid 1px #999'><a class='smalltitle'><strong>No Current Reviews</strong></a></td>
        							 </tr>
        						 </table>"		 
          end
  				return result
			end
=end  
  private 
  
  def getTableRow(num, times, scale=1)
    ans = ""
    tmp_schedule = times.dclone
    5.times{|n|
      n = n+1
      found = false
      for course_time in tmp_schedule
        if(!found && course_time[0].wday == n)
          start_time = course_time[0].hour
          end_time = course_time[1].hour
          if(scale==2)
            if(course_time[0].min+1>15)
              start_time = start_time + 0.5
            elsif(course_time[0].min+1>45)
              start_time = start_time + 0.5
            end
            if(course_time[1].min+1>15)
              end_time = end_time + 0.5
            elsif(course_time[1].min+1>45)
              end_time = end_time + 0.5
            end
          end
          if(start_time == num)
            rspan = end_time - start_time
						ans = ans + "<td bgcolor='#DED1ED' rowspan=#{(rspan*scale).to_i} ><font size='1' face='Verdana'>&nbsp;</font></td>"
						found = true
						tmp_schedule.delete(course_time)
						elsif(num > start_time && num < end_time)
            found = true
          end
        end
      end
      if(!found)
        ans = ans + "<td><font size='1' face='Verdana'>&nbsp;</font></td>"
      end
    }
    return ans
  end
  
end
