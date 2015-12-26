module PhotoCook
  module Command
    # Proportional support
    # http://stackoverflow.com/questions/7200909/imagemagick-convert-to-fixed-width-proportional-height
    #
    # Device pixel ratio collection
    # http://dpi.lv/
    # http://www.canbike.org/CSSpixels/
    def command_regex
      @command_regex ||= %r{
          width:       (?<width>      auto|\d{1,4}) &
          height:      (?<height>     auto|\d{1,4}) &
          crop:        (?<crop>       [10]) &
          pixel_ratio: (?<pixel_ratio>[1234])
        }x
    end

    # NOTE: This method performs no validation
    def assemble_command(width, height, pixel_ratio, crop)
      "width=#{  width  == 0 ? 'auto' : width}&" +
      "height=#{ height == 0 ? 'auto' : height}&" +
      "crop=#{   crop ? '1' : '0'}&" +
      "pixel_ratio=#{pixel_ratio.ceil}"
    end
  end
  extend Command
end