class Teacher < ActiveRecord::Base
  
  has_many :courses
  
  Teacher.partial_updates = false
  serialize :photolocation_vote_map
  serialize :user_vote_map
  
  #Constants
  TEACHER_NOTLISTED = -2 #no teacher assigned yet
  TEACHER_NOTFOUND = -1 #Regex failed
  DEFAULT_IMAGE_LOCATION = "teachers/default.png"
  
  def self.get_teacher_id(name)
    name = prepare_name(name)
    if(name.empty?)
      return TEACHER_NOTFOUND #Regex failed
    else
      teacher = Teacher.find_by_name(name)
      if(teacher.nil?)
        teacher = Teacher.create(:name=>name)
      end
      return teacher.id   
    end    
  end
  
  def self.prepare_name(name)
    if(/,/.match(name))  #BRIGGS,DAVID G  to DAVID G BRIGGS
       name_split = name.split(",")
       name = name_split[1].strip + " " + name_split[0].strip
    end
    return name.strip
  end
  
  def courses_present(year, quarter)
    Course.find(:all, :conditions => {:teacher_id=>self.id, :year=>year, :quarter_id=>quarter})
  end
  
  def courses_past(year, quarter)
    Course.find(:all, :conditions => "teacher_id = '#{self.id}' AND (year < '#{year}' OR (year = '#{year}' AND quarter_id < '#{quarter}'))")
  end
  
  def courses_future(year, quarter)
    Course.find(:all, :conditions => "teacher_id = '#{self.id}' AND (year > '#{year}' OR (year = '#{year}' AND quarter_id > '#{quarter}'))")
  end
  
  def self.vote_for_photo(teacher, location, curr_user)
    old_loc = teacher.user_vote_map[curr_user.id]
    if(old_loc!=location)
      teacher.user_vote_map[curr_user.id] = location
      if(old_loc!=nil)
        teacher.photolocation_vote_map[old_loc] = teacher.photolocation_vote_map[old_loc] - 1
      else
        teacher.total_photo_votes = teacher.total_photo_votes + 1
      end
      if(teacher.photolocation_vote_map!=nil)
        teacher.photolocation_vote_map[location] = teacher.photolocation_vote_map[location] + 1
      else
        teacher.photolocation_vote_map[location] = 1
      end
    end
    teacher.save!
  end
  
  def self.upload_photo(teacher, upload, curr_user)
    path = ""
    message = "Upload successful"
    begin
      if(teacher.next_photo_name==nil)
        teacher.next_photo_name = 0
      end
      tmp = upload['datafile'].original_filename.split(".")
      name =  "#{teacher.id}_#{teacher.next_photo_name}."+tmp[tmp.length-1]
      directory = "public/images/teachers"
      # create the file path
      path = File.join(directory, name)
      # write the file
      File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
    rescue
      message = "Failed to upload"
    end
    begin
      teacher.next_photo_name = teacher.next_photo_name + 1
      if(teacher.user_vote_map == nil || teacher.user_vote_map[curr_user.id]==nil)
        if(teacher.total_photo_votes==nil)
          teacher.total_photo_votes = 0
        end
        teacher.total_photo_votes = teacher.total_photo_votes + 1
      elsif(teacher.user_vote_map!=nil && teacher.user_vote_map[curr_user.id]!=nil)
        old_path = teacher.user_vote_map[curr_user.id]
        teacher.photolocation_vote_map[old_path] = teacher.photolocation_vote_map[old_path] - 1
      end
      if(teacher.user_vote_map!=nil)
        teacher.user_vote_map.store(curr_user.id, path)
      else
        teacher.user_vote_map = {curr_user.id=>path}
      end
      if(teacher.photolocation_vote_map==nil)
        teacher.photolocation_vote_map = {path=>1}
      else
        teacher.photolocation_vote_map.store(path, 1)
      end
      teacher.save!
    rescue
        message = "Failed to upload(stage 2)"
        #undo upload file because other operations were not done successfully
        if(File.exist?(path))
          File.delete(path)
        end
    end
    return message
  end
  
  def current_photo_location(options={})
    if(self.photolocation_vote_map!=nil)
    sorted_photos = self.photolocation_vote_map.sort{|a,b| 0-(a[1] <=> b[1])}
    else
      sorted_photos = nil
    end
    location = ""
    if(sorted_photos!=nil && sorted_photos.length>0)
      if(options[:long_location])
        location = sorted_photos[0][0]
      else
        location = sorted_photos[0][0].split("images/")[1]
      end
      votes = sorted_photos[0][1]
    else
      if(options[:long_location]) 
        location = "public/images/"+DEFAULT_IMAGE_LOCATION
      else
        location = DEFAULT_IMAGE_LOCATION
      end
      votes = 0
    end
    
    if(options[:all_info])
      return [location, votes]
    else
      return location
    end
    
  end
  
  def runners_up_photo_locations
    all_sorted = self.sorted_photolocation_vote_map
    if(all_sorted != nil)
      all_sorted.shift
    end
    return all_sorted
  end
  
  def user_vote_photo_location(curr_user, options={})
    original = self.user_vote_map[curr_user.id]
    tmp = original
    if(!options[:long_location])
      tmp = original.split("images/")[1]
    end
    if(options[:all_info])
      return [tmp,self.photolocation_vote_map[original]]
    end
    return tmp
  end
  
  def sorted_photolocation_vote_map
    if(self.photolocation_vote_map!=nil)
      return self.photolocation_vote_map.sort{|a,b| 0-(a[1] <=> b[1])}
    else
      return nil
    end
  end
  
  def teacher_info_at_index(teacher_info_index)
    return TeacherInfo.find_by_sql("SELECT * FROM teacher_infos WHERE teacher_id=#{self.id} ORDER BY total_confirmations DESC, id DESC LIMIT #{teacher_info_index},1")[0]
  end
  
  def self.generate_search_query(search_text)
    tokens = Course.search_tokenize(search_text)
    tokens = tokens - ["it", "and",  "or", "as", "to", "offered", "jointly", "recommended", "prerequisite", "the", "are", "a", "an", "about", "above", "across", "after", "against", "along", "among", "around", "at", "before", "behind", "below", "beneath", "beside", "between", "beyond", "but", "by", "despite", "down", "during", "except", "for", "from", "in", "inside", "into", "like", "near", "of", "off", "on", "onto", "out", "outside", "over", "past", "since", "through", "throughout", "till", "to", "toward", "under", "underneath", "until", "up", "upon", "with", "within", "without"]
    change_symbol = "<!!>"
    while(tokens.include?(change_symbol))
      change_symbol = change_symbol + ">"
    end
    base_query = ""
    first = true
    tokens.each(){|tok|
      if(first)
        base_query = base_query + " #{change_symbol}='#{tok}'"
        first = false
      else
        base_query = base_query + " OR #{change_symbol}='#{tok}'"
      end
    }
    model_str = "(Select *, Sum(position) as position_sum From "
    model_str = model_str + "(Select t.*, 100 as position From teachers t Where (#{base_query.gsub(Regexp.new(change_symbol+"=\\'(.*?)\\'")){|s| "t.name Like '#{$1}%'"}}) Union Select t.*, 101 as position From teachers t Where (#{base_query.gsub(Regexp.new(change_symbol+"=\\'(.*?)\\'")){|s| "t.name Like '%#{$1}'"}})"
    model_str = model_str + " ) res Group By res.id) teachers"
    return model_str
  end
  
  def self.find_by_search_text(search_text, options={})
    model_str = generate_search_query(search_text)
    return Teacher.find_by_sql("Select * From #{model_str} Order By teachers.position_sum DESC#{(options[:limit]!=nil)? ' LIMIT '+options[:limit].to_s : ''}")
  end
  
end
