# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
def military_to_standard_hour(hour)
  if(hour>12)
    hour -= 12
  end
  return hour
end

def generate_credits_image(course)
  html = "<div class='credits' align='right'>"
  html << "<p class='creditsnum'>#{course.credits}"
  if(!course.variable_credit.nil?)
    html << "-#{course.variable_credit}"
  end
  html << "<\/p>Credits<\/div>"
  return html
end

def generate_enrollment_image(course)
  html = ""
  if (!(course.students_enrolled.nil? || course.enrollment_space.nil?))
      enroll_frac = course.students_enrolled/course.enrollment_space
      html << "<div class="
      if(enroll_frac < 0.5)
        html << "'classfullness'"
      elsif(enroll_frac < 0.75)
        html << "'classfullness semi'"
      else
        html << "'classfullness full'"
      end
      html << ">"
  else
      html << "<div class='classfullness'>"
  end
  html << "<div class='numerator'><p class='number'>"
  if(!course.students_enrolled.nil?)
    html << course.students_enrolled.to_s
  else
    html << "Unavailable"
  end
  html << "</p>Enrolled</div><div class='denominator'><p class='number'>"
  if(!course.enrollment_space.nil?)
    html << course.enrollment_space.to_s
  else
    html << "Unavailable"
  end
  html << "</p>Possible</div>"
  html << "</div>"
  return html
end

def generate_schedule(rendezvous, options={})
  by_hour = true
  show_times = true
  show_days = true
  show_text_schedule = true
  start_hour = 7
  end_hour = 20
  identify = nil
  display_text = nil
  color = nil
  table_class = "smallschedule"
  draggable_divs = false
  
  if(options[:by_hour]!=nil && (options[:by_hour].kind_of?(TrueClass) || options[:by_hour].kind_of?(FalseClass)))
    by_hour = options[:by_hour]
  end
  if(options[:start_hour]!=nil && options[:start_hour].kind_of?(Fixnum))
    start_hour = options[:start_hour]
  end
  if(options[:end_hour]!=nil && options[:end_hour].kind_of?(Fixnum))
    end_hour = options[:end_hour]
  end
  if(options[:show_times]!=nil)
    show_times = options[:show_times]
  end
  if(options[:show_days]!=nil)
    show_days = options[:show_days]
  end
  if(options[:show_text_schedule]!=nil)
    show_text_schedule = options[:show_text_schedule]
  end
  if(options[:identify]!=nil)
    identify = options[:identify]
  end
  if(options[:display_text]!=nil)
    display_text = options[:display_text]
  end
  if(options[:color]!=nil)
    color = options[:color]
  end
  if(options[:table_class]!=nil)
    table_class = options[:table_class]
  end
  if(options[:draggable_divs]!=nil)
    draggable_divs = options[:draggable_divs]
  end
  if(rendezvous==nil)
    rendezvous = {}
  end
  
  default_rowspan = (by_hour)? 2 : 1
  num_class_blocks = 0
  
  rows = []
  6.times{|j|
    span_count = 0
    ((end_hour-start_hour)*2).times{|i|
      if(i%2==0)
        if(j==0)
          if(show_times)
            rows[i] = "<tr><td rowspan=#{default_rowspan} class='time'>#{military_to_standard_hour(start_hour+(i/2))}:00</td>"
            if(by_hour)
              rows[i+1] = "<tr>"
            else
              rows[i+1] = "<tr><td rowspan=#{default_rowspan} class='time'>#{military_to_standard_hour(start_hour+(i/2))}:30</td>"
            end
          else
            rows[i] = "<tr><td rowspan=#{default_rowspan} class='place'></td>"
            if(by_hour)
              rows[i+1] = "<tr>"
            else
              rows[i+1] = "<tr><td rowspan=#{default_rowspan} class='place'></td>"
            end
          end
        else
          if(span_count==0 && rendezvous!=nil)
            place_half = false
            for rende in rendezvous
              k = 0
              while(k < rende.times.size)
                adjusted_hour = ((rende.times[k][0].min>=50)? rende.times[k][0].hour+1 : rende.times[k][0].hour)
                if(rende.times[k][0].wday == j && rende.times[k][0].hour == (start_hour+(i/2)))
                  if(rende.times[k][0].min < 20)
                    span_count = 2*(rende.times[k][1].hour - rende.times[k][0].hour)
                  elsif(rende.times[k][0].min >= 20)
                    span_count = 2*(rende.times[k][1].hour - rende.times[k][0].hour)
                    place_half = true
                  end
                  if(rende.times[k][1].min >= 50)
                    span_count += 2
                  elsif(rende.times[k][1].min >= 20)
                    span_count += 1
                  end
                end
                k+=1
              end
            end
            if(span_count>0)
              iden = ((identify!=nil)? "id='#{identify}_#{num_class_blocks}'" : "")
              style = "style='"
              style = ((draggable_divs)? style+" cursor:move;" : style)
              style = ((color!=nil)? style+" background-color:#"+color+";" : style)
              style = style+"'"    
              if(place_half)
                rows[i] += "<td rowspan=1 class='halfsize'></td>"#used to say just half!
                if(span_count>1)
                  rows[i+1] += "<td valign='top' #{style} rowspan=#{span_count-1} #{(!draggable_divs)? "class='class'" : "class='holderclass'"} #{iden}>#{((draggable_divs)? "<div class='class' style='height:#{0*(span_count-1)+26}px; cursor:move;'>#{display_text.gsub("$^$block_num$^$", num_class_blocks.to_s)}</div>" : "")}</td>"
                  num_class_blocks += 1
                end
              else
                rows[i] += "<td valign='top' #{style} rowspan=#{span_count} #{(!draggable_divs)? "class='class'" : "class='holderclass'"} #{iden}>#{((draggable_divs)? "<div class='class' style='height:#{0*span_count+26}px; cursor:move;'>#{display_text.gsub("$^$block_num$^$", num_class_blocks.to_s)}</div>" : "")}</td>"
                num_class_blocks += 1
              end
            end
          end
          if(span_count == 0)
            rows[i] += "<td rowspan=#{default_rowspan} class='normal'></td>"
            if(!by_hour)
              rows[i+1] += "<td rowspan=#{default_rowspan} class='normal'></td>"
            end
          elsif(span_count > 0)
            if(span_count==1)
              rows[i+1] += "<td rowspan=1 class='halfsize'></td>"
              span_count = 0
            else
              span_count -= 2
            end
          end
        end
      end
    }
  }
  st = "<table class='#{table_class}'> \n"
  days = "<tr> \n
            #{(show_times)? '<td class=\'blank\'></td>' : ''}
            <td class='tableheader'>M</td> \n
            <td class='tableheader'>Tu</td> \n
            <td class='tableheader'>W</td> \n
            <td class='tableheader'>Th</td> \n
            <td class='tableheader'>F</td> \n
          </tr> \n"
  if(show_days)
    st += days
  end
  rows.size.times{|i|
  st += rows[i]+"</tr> \n"
  }
  st += "</table>"
  buildings_hash = {}
  if(show_text_schedule && rendezvous!=nil)
    for rende in rendezvous
      if(!buildings_hash.key?([rende.building_id, rende.room]))
        buildings_hash[[rende.building_id, rende.room]] = {}
      end
      times_hash = buildings_hash[[rende.building_id, rende.room]]
      for duration in rende.times
        found = false
        times_hash.each_key{|k| if(k[0].hour == duration[0].hour && k[0].min == duration[0].min && k[1].hour == duration[1].hour && k[1].min == duration[1].min)
                                  times_hash[k].push(duration[0].wday)
                                  found = true
                                  break
                                end
                           }
        if(!found)
          times_hash[duration] = [duration[0].wday]
        end
      end
    end
    text_sched = ""
    buildings_hash.each_key{|k| 
      if(k[0]<0)
        building_abbrev = "Unknown"
        building_id = -1
      else
        building = Building.find(k[0])
        building_abbrev = building.abbrev
        building_id = building.id
      end
      text_sched += "#{link_to(building_abbrev, :controller=>'buildings', :action=>'map', :id=>building_id)} #{k[1]}:\t"
      buildings_hash[k].each_key{|duration|
                                  wdayst = ""
                                  wdays = ["Su", "M", "T", "W", "Th", "F", "Sa"]
                                  buildings_hash[k][duration].each{|d| wdayst += " #{wdays[d]}"}
                                  text_sched += "#{wdayst} #{duration[0].strftime('%I:%M')}-#{duration[1].strftime('%I:%M')}<br/>"
      }
    }
    st += "<div class='classtime'>#{text_sched}</div>"
  end
  if(draggable_divs)
    return [st, num_class_blocks]
  else
    return st
  end
end

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
  
  def bread_crumbs(category_or_course, options={})
    include_self_link = false
    include_x_links = true
    limitors = nil
    base_url_hash = {:controller=>"categories", :action=>"index"}
    limitors_name = :limitors
    
    if(options[:include_self_link]!=nil)
      include_self_link = options[:include_self_link]
    end
    if(options[:include_x_links]!=nil)
      include_x_links = options[:include_x_links]
    end
    if(options[:base_url_hash])
      base_url_hash = options[:base_url_hash]
    end
    if(options[:limitors_name]!=nil)
      limitors_name = options[:limitors_name]
    end
    if(options[limitors_name]!=nil)
      limitors = options[limitors_name]
    end
    if(options[:familypath]!=nil)
      familypath = options[:familypath]
    else
      familypath = []
    end
    
    result = ""
    if(category_or_course!=nil)
      familypath.insert(0, category_or_course)
      while( (category_or_course.is_a?(Course))? category_or_course.category!=nil : category_or_course.parents[0]!=nil)
        if(category_or_course.is_a?(Course))
          familypath.push(category_or_course.category)
          category_or_course = category_or_course.category
        else
          familypath.push(category_or_course.parents[0])
          category_or_course = category_or_course.parents[0]
        end
      end
      
      str_fill = ""
      parent2 = category_or_course
  	  while (parent = familypath.pop)!=nil
  	    if(parent.is_a?(Course))
  	      if(!familypath.empty? || include_self_link)
  	        result = result + str_fill + link_to("SLN: #{parent.sln}", :controller=>"courses", :action=>"index", :id=>parent.id)
  	      else
  	        result = result + str_fill + "SLN: #{parent.sln}"
  	      end
  	    else
  	      if(!familypath.empty? || include_self_link)
  	        base_url_hash[:id] = parent.id
  	        result = result + str_fill + link_to(parent.name, base_url_hash)
  	      else
  	        result = result + str_fill + parent.name
  	      end
  	    end
  	    parent2 = parent
  	    base_url_hash[:id] = parent2.id
  	    str_fill = " > "
  	  end
    end
	  if(limitors!=nil && limitors.size>0 && limitors[:order]!=nil)
	    to_result = ""
	    tmp_limitors = limitors.clone
	    tmp_limitors[:order] = tmp_limitors[:order].clone
	    if(tmp_limitors["custom"]!=nil)
	      tmp_limitors["custom"] = tmp_limitors["custom"].clone
	    end
	    tmp2_limitors = limitors.clone
	    tmp2_limitors[:order] = tmp2_limitors[:order].clone
      if(tmp2_limitors["custom"]!=nil)
        tmp2_limitors["custom"] = tmp2_limitors["custom"].clone
      end
      tmp3_limitors = limitors.clone
	    tmp3_limitors[:order] = tmp3_limitors[:order].clone
      if(tmp3_limitors["custom"]!=nil)
        tmp3_limitors["custom"] = tmp3_limitors["custom"].clone
      end
	    order = limitors[:order].clone
	    size = order.size-1
      order.each_index{|index|
	      i = size - index
	      item = order[i]
        if(item.include?("custom"))
          arr = item.split("..")
          spot = arr[1].to_i
          display = arr[2]
          tmp = tmp_limitors["custom"][spot]
          base_url_hash[limitors_name] = tmp2_limitors
          tmp_str = " > "+ link_to(display, base_url_hash)
          tmp_limitors["custom"].delete_at(spot)
          tmp_limitors[:order].delete_at(i)
          if(i<tmp_limitors[:order].size && tmp_limitors[:order][i].include?("custom"))
            tmp_array = tmp_limitors[:order][i].split("..")
            tmp_array[1] = (tmp_array[1].to_i)-1
            tmp_limitors[:order][i] = "#{tmp_array[0]}..#{tmp_array[1]}..#{tmp_array[2]}"
          end  
          tmp2_limitors["custom"].delete_at(spot)
          tmp2_limitors[:order].delete_at(i)
          if(include_x_links)
            base_url_hash[limitors_name] = tmp_limitors
            to_result = tmp_str + "(" + link_to("x", base_url_hash) + ")" + to_result
          else
            to_result = tmp_str + to_result
          end
          tmp_limitors["custom"].insert(spot, tmp)
          tmp_limitors[:order].insert(i, item)
        else
          class_hash = {"teacher" => Teacher}
          value = tmp_limitors[item]
          disp_item = item
          disp_val = value
          if(item == "course_name")
            disp_item = "course name"
          elsif(item.include?("_id"))
            disp_item = item.split("_")[0]
            if(class_hash[disp_item]!=nil)
              disp_val = class_hash[disp_item].find(value).name
            end
          elsif(item == "specific_quarter")
            tmpar = value.split("..")
            disp_item = "quarter"
            disp_val = "#{Quarter.quarter_disp_name(tmpar[0].to_i)} #{tmpar[1]}"
          end
            
          display = "#{disp_item}: #{disp_val}"
          base_url_hash[limitors_name] = tmp2_limitors
          tmp_str = " > "+ link_to(display, base_url_hash)
          tmp2_limitors.delete(item)
          tmp2_limitors[:order].delete_at(i)
          tmp3_limitors.delete(item)
          tmp3_limitors[:order].delete_at(i)
          if(include_x_links)
            base_url_hash[limitors_name] = tmp3_limitors
            to_result = tmp_str + "("+ link_to("x", base_url_hash) + ")" + to_result
          else
            to_result = tmp_str + to_result
          end
          tmp3_limitors[item] = value
          tmp3_limitors[:order].insert(i, item)
        end
      }
      result = result + to_result
	  end
	  return result
  end
  
  def add_to_limitors(params, place, value, options={})
    do_not_overide = false
    display = ""
    do_not_add_to_order = false
    limitors_name = :limitors
    
    if(options[:do_not_overide]!=nil)
      do_not_overide = options[:do_not_overide]
    end
    if(options[:display]!=nil)
      display = options[:display]
    end
    if(options[:do_not_add_to_order]!=nil)
      do_not_add_to_order = options[:do_not_add_to_order]
    end
    if(options[:limitors_name]!=nil)
      limitors_name = options[:limitors_name]
    end
    if(params[limitors_name]==nil)
      params[limitors_name] = {}
    end
    
    if(place=="custom")
      if(params[limitors_name]["custom"]==nil || !params[limitors_name]["custom"].include?(value) || !do_not_overide)
        if(params[limitors_name]["custom"]==nil)
          params[limitors_name]["custom"] = []
        end
        params[limitors_name]["custom"].push(value)
        place = "custom..#{params[limitors_name]['custom'].size-1}..#{display}"
      else
        place = nil
      end
    else
      if(!params[limitors_name].key?(place) || !do_not_overide)
        params[limitors_name][place] = value
      else
        place = nil
      end
    end
    
    if(place!=nil && !do_not_add_to_order)
      if(params[limitors_name][:order]==nil)
        params[limitors_name][:order] = []
      end
      params[limitors_name][:order].push(place)
      place = params[limitors_name][:order].size - 1
    elsif(params[limitors_name]=={})
      params.delete(limitors_name)
    end
    return place
  end
  
  def delete_from_limitors(params, position, options={})
    limitors_name = :limitors
    
    if(options[:limitors_name]!=nil)
      limitors_name = options[:limitors_name]
    end
    
    if(position!=nil && params[limitors_name]!=nil && params[limitors_name][:order]!=nil)
      place = params[limitors_name][:order][position]
      if(place.include?("custom"))
        tmp = place.split("..")
        params[limitors_name]["custom"].delete_at(tmp[1].to_i)
      else
        params[limitors_name].delete(place)
      end
      params[limitors_name][:order].delete_at(position)
    end
  end
  
  def review_percent_table(reviews, total_reviews, options={})
		all = [0,0,0,0,0]
    average = 0.0
    for review in reviews
      rating = review.rating
      average += rating
      all[rating - 1] += 1
    end
    if(total_reviews.nil?)
      total_reviews = 0
    end
    average /= total_reviews
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
				  if(options[:links]!=nil)
						bartable << "<td>"+link_to( all[i-1].to_s+" reviews", :controller=>"course_reviews", :action=>"index", :id=>options[:links], :rating_val=>i) +"</td>"
					end
          bartable << "</tr>"
		}
		bartable << "<tr><td>Average rating: #{average.to_s}</td></tr>"
		bartable << "</table>"
		return bartable
  end
	
	def formatted_course_review(course_review, course)
	  teacher = Teacher.find(course_review.teacher_id)
	  taken_s = Quarter.quarter_disp_name(course_review.quarter_taken) + " " + course_review.year_taken.to_s
	  valid_course = Course.find(:first, :conditions => "quarter_id=#{course_review.quarter_taken} AND year=#{course_review.year_taken} AND title='#{course.title}'")
	  return "<table width='100%'>
	              <tr><td>
                  <table width='100%'>
	                  <tr>
                      <td valign='top'><a class='smalltitle' style='font-size:1.1em;'><strong>#{course_review.review_name}</strong></a></td>
                      <td align='right'>#{star_ratings(course_review.rating, "24x24")}</td>
                    </tr>
                  </table>
                </td></tr>
                <tr><td><strong>Reviewed By:</strong> #{(course_review.author!=nil)? course_review.author.login : 'Anonymous'} <strong>on</strong> #{course_review.created_at}</td></tr>
                <tr><td><strong>Quarter taken:</strong>&nbsp;#{ ((!valid_course.nil?)? link_to(taken_s, :controller=>'courses', :action=>'index', :id=>valid_course.id) : taken_s)}</td></tr>
            		<tr><td><strong>Taught by:</strong>&nbsp;#{link_to(teacher.name, :controller=>'teachers', :action=>'index', :id=>teacher.id)}</td></tr>
	              <tr><td><strong>Pros:</strong>&nbsp;#{course_review.pros}</td></tr>
	              <tr><td><strong>Cons:</strong>&nbsp;#{course_review.cons}</td></tr>
	              <tr><td><strong>Other Thoughts:</strong>&nbsp;#{course_review.other_thoughts}</td></tr>
             </table>"
  end
	
	def formatted_teacher_review(teacher_review)
	  return "<tr>
	            <td height='1' style='border-bottom:solid 1px; #999'><a class='smalltitle'><strong>#{teacher_review.name}</strong></a></td>
	            <tr><td><table width='100%'><tr><td valign='top'>Reviewed By: #{(teacher_review.author!=nil)? teacher_review.author.login : 'Anonymous'} on #{teacher_review.created_at}</td><td align='right'>#{star_ratings(teacher_review.rating, "24x24")}</td></tr></table></td></tr>
	            <tr><td>Class taught: </tr></td><br>
	            <tr><td><strong>Pros:</strong>&nbsp;#{teacher_review.pros}</td></tr><br>
              <tr><td><strong>Cons:</strong>&nbsp;#{teacher_review.cons}</td></tr><br>
              <tr><td><strong>Other Thoughts:</strong>&nbsp;#{teacher_review.other_thoughts}</td></tr>
	         "
	end
        		   
  def votable_image(location, vote_count, total_votes, vote_url, curr_user, options={})
      pic_size = ImageSpec::Dimensions.new(location)
      pic_width = pic_size.width
      pic_height = pic_size.height
      if(total_votes==nil)
        total_votes = 0
      end
      if(options[:max_width]!=nil && ((pic_width - options[:max_width]) > (pic_height - ((options[:max_height]!=nil)? options[:max_height] : pic_height))) &&  pic_width > options[:max_width])
        pic_height = (options[:max_width]*pic_height)/pic_width
        pic_width = options[:max_width]
      elsif(options[:max_height]!=nil && pic_height > options[:max_height])
        pic_width = (options[:max_height]*pic_width)/pic_height
        pic_height = options[:max_height]
      end
      percent = "#{((vote_count*1.0)/total_votes)*100}%"
      top_lettering_pos = pic_height-20
      if(location.index("public")<=1)
        location = location.split("public")[1]
      end
      vote_button = ""
      if(vote_url!=nil)
        vote_button = "<div style='float:left;padding-left:5px;padding-top:#{top_lettering_pos}px;'><a class='vote_b' href='#{vote_url}'>Vote</a></div>"
      end
      return "<div id='vote_image' style='width:#{pic_width}px;height:#{pic_height}px;'>
                <div style='z-index:0;position:absolute;'>#{image_tag(location, :size=>(pic_width.to_s+'x'+pic_height.to_s))}</div>
                <div style='z-index:1;position:absolute;width:#{pic_width}px;height:#{pic_height}px;'>
                  #{((location!=Teacher::DEFAULT_IMAGE_LOCATION && location!=('/images/'+Teacher::DEFAULT_IMAGE_LOCATION)) && !curr_user.tmp_user)? vote_button : ""}
                  <div style='float:right;padding-right:5px;padding-top:#{top_lettering_pos}px;'><span class='vote_percent'>#{(location!=Teacher::DEFAULT_IMAGE_LOCATION && location!=('/images/'+Teacher::DEFAULT_IMAGE_LOCATION))? percent.to_i.to_s+'%' : ''}</span></div>
                </div>
              </div>"
  end
						
=begin  
  #{image_tag(location, :size=>(pic_width.to_s+'x'+pic_height.to_s))}
      def class_review_summary(course)
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
