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
        \A
          width=       (?<width>      auto|\d{1,4}) &
          height=      (?<height>     auto|\d{1,4}) &
          pixel_ratio= (?<pixel_ratio>[1234]) &
          crop=        (?<crop>       yes|no)
        \z
        }x
    end

    # NOTE: This method performs no validation
    def assemble_command(width, height, pixel_ratio, crop)
       'width='       + encode_dimension(width) +
      '&height='      + encode_dimension(height) +
      '&pixel_ratio=' + encode_pixel_ratio(pixel_ratio) +
      '&crop='        + encode_crop_option(crop)
    end

    def extract_command(resize_uri)
      resize_uri.split('/')[-2].match(command_regex)
    end

    def decode_crop_option(crop)
      crop == 'yes'
    end

    def encode_crop_option(crop)
      crop ? 'yes' : 'no'
    end

    def encode_dimension(val)
      val == 0 ? 'auto' : val.to_s
    end

    def encode_pixel_ratio(ratio)
      ratio.ceil.to_s
    end
  end
  extend Command
end