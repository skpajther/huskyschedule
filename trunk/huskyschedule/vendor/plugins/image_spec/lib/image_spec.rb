require 'parsers/jpeg.rb'
require 'parsers/png.rb'
require 'parsers/gif'
require 'parsers/swf'

module ImageSpec
  
  class Dimensions
    attr_reader :width, :height
    
    def initialize(file)
      # Depending on the type of our file, parse accordingly
      case File.extname(file)
        when ".swf", ".SWF"
          @width, @height = SWF.dimensions(file)
        when ".jpg", ".jpeg", ".JPG", ".JPEG"
          @width, @height = JPEG.dimensions(file)
        when ".gif", ".GIF"
          @width, @height = GIF.dimensions(file)
        when ".png", ".PNG"
          @width, @height = PNG.dimensions(file)
        else
          raise "Unsupported file type. Sorry bub :( #{file}"
      end
    end
    
  end
  
end