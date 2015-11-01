module PhotoCook
  module CommandRegex
    # Proportional support
    # http://stackoverflow.com/questions/7200909/imagemagick-convert-to-fixed-width-proportional-height
    def command_regex
      unless @command_regex
        w = /(?<width>\d+)/
        h = /(?<height>\d+)/
        @command_regex = %r{
          \- (?:(?:#{w}x#{h}) | (?:#{w}x) | (?:x#{h})) (?<crop>crop)? \z
        }x
      end
      @command_regex
    end
  end
  extend CommandRegex
end