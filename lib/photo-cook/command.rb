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
          width=       (?<width>      auto|\d{1,4}) &
          height=      (?<height>     auto|\d{1,4}) &
          pixel_ratio= (?<pixel_ratio>[1234]) &
          crop=        (?<crop>       yes|no)
        }x
    end

    # NOTE: This method performs no validation
    def assemble_command(width, height, pixel_ratio, crop)
      "width=#{  width  == 0 ? 'auto' : width}&" +
      "height=#{ height == 0 ? 'auto' : height}&" +
      "pixel_ratio=#{pixel_ratio.ceil}&" +
      "crop=#{   bool_to_crop(crop)}&"
    end

    def crop_to_bool(crop)
      crop == 'yes'
    end

    def bool_to_crop(crop)
      crop ? 'yes' : 'no'
    end
  end
  extend Command
end