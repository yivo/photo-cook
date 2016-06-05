# frozen_string_literal: true
module PhotoCook
  module Resize
    module Command
      class << self
        # Proportional support
        # http://stackoverflow.com/questions/7200909/imagemagick-convert-to-fixed-width-proportional-height
        #
        # Device pixel ratio collection
        # http://dpi.lv/
        # http://www.canbike.org/CSSpixels/
        def regex
          @regex ||= /\A(?<mode>fit|fill)\-(?<width>\d+)x(?<height>\d+)\z/
        end

        # NOTE: This method performs no validation
        # NOTE: This method is very hot
        def assemble(width, height, mode)
          "#{mode}-#{width}x#{height}"
        end

        def extract(resize_uri)
          resize_uri.split('/')[-2].match(@regex)
        end
      end
    end
  end
end
