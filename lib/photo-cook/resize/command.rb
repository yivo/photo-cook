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
          @regex ||= %r{
            \A
              w=   (?<width>  \d+) &
              h=   (?<height> \d+) &
              mode=(?<mode>   fit|fill)
            \z
            }x
        end

        # NOTE: This method performs no validation
        # NOTE: This method is very hot
        def assemble(width, height, mode)
           'w='    + width.to_s  +
          '&h='    + height.to_s +
          '&mode=' + (mode.kind_of?(Symbol) ? mode.to_s : mode )
        end

        def extract(resize_uri)
          resize_uri.split('/')[-2].match(@regex)
        end
      end
    end
  end
end
