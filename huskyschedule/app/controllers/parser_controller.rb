class ParserController < ApplicationController
  
  def parse
    aut09 = Parser.time_schedule_parser("http://www.washington.edu/students/timeschd/AUT2009/")
    #spring = Parser.time_schedule_parser("http://www.washington.edu/students/timeschd/SPR2009/")
  end
  
end
