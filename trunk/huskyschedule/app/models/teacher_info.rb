class TeacherInfo < ActiveRecord::Base
    Course.partial_updates = false
    serialize :other
end
