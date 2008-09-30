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
  
  def star_ratings(rating, total_ratings)
    i=0
    result = ""
		i.times{
			result = result + "<img src='/images/stars/star32x32.png'/>"
		}
		(5-i).times{
			result = result + "<img src='/images/stars/star_blank32x32.png'/>"
		}
		return result
  end
  
  def bread_crumbs(category_or_course)
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
	      if(!@familypath.empty?)
	        result = result + " > " + link_to("SLN: #{parent.sln}", :controller=>"courses", :action=>"index", :id=>parent.id)
	      else
	        result = result + " > " + "SLN: #{parent.sln}"
	      end
	    else
	      if(!@familypath.empty?)
	        result = result + " > " + link_to(parent.name, :controller=>"categories", :action=>"index", :id=>parent.id)
	      else
	        result = result + " > " + parent.name
	      end
	    end
	  end
	  return result
  end
  
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
