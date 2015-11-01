module PhotoCook
  module Dimensions
    def parse_and_check_dimensions(width, height)
      width   = width   == :auto ? 0 : width.to_i
      height  = height  == :auto ? 0 : height.to_i
      check_dimensions!(width, height)
      [width, height]
    end

    def check_dimensions!(width, height)
      raise ArgumentError, 'Expected positive numbers' unless valid_dimensions?(width, height)
    end

    def valid_dimensions?(width, height)
      width >= 0 && height >= 0
    end

    def multiply_and_round_dimensions(ratio, width, height)
      [(width * ratio).round, (height * ratio).round]
    end

    def literal_dimensions(width, height)
      "#{width == 0 ? nil : width}x#{height == 0 ? nil : height}"
    end
  end
  extend Dimensions
end