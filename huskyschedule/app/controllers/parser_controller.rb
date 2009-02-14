class ParserController < ApplicationController
  
  def parse
    #@winter = Parser.time_schedule_parser("http://www.washington.edu/students/timeschd/WIN2009/")
    @spring = Parser.time_schedule_parser("http://www.washington.edu/students/timeschd/SPR2009/")
  end
  
end
