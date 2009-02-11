class ParserController < ApplicationController
  
  def parse
    @message = Parser.time_schedule_parser("http://www.washington.edu/students/timeschd/SPR2009/")
  end
  
end
