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
          w=   (?<width>      auto|\d{1,4}) &
          h=   (?<height>     auto|\d{1,4}) &
          mode=(?<mode>       fit|fill)
        \z
        }x
    end

    # NOTE: This method performs no validation
    # NOTE: This method is very hot
    def assemble_command(width, height, mode)
       'w='    + encode_dimension(width)  +
      '&h='    + encode_dimension(height) +
      '&mode=' + encode_mode(mode)
    end

    def extract_command(resize_uri)
      resize_uri.split('/')[-2].match(command_regex)
    end

    def decode_mode(mode)
      mode
    end

    def encode_mode(mode)
      mode == true ? 'fill' : (mode == false ? 'fit' : mode.to_s)
    end

    def encode_dimension(val)
      val == 0 ? 'auto' : val.to_s
    end
  end
  extend Command
end
