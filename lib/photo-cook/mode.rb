module PhotoCook
  module Mode
    def parse_and_check_mode(mode)
      case mode
        when true then :fill
        when false then :fit
        when :fit, :fill then mode
        when 'fit', 'fill' then mode.to_sym
        else raise 'Mode mode mode'
      end
    end
  end

  extend Mode
end
