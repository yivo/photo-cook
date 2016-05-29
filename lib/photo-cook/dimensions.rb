module PhotoCook
  module Dimensions
    def parse_and_check_dimensions(untrusted_width, untrusted_height)
      width  = untrusted_width  == :auto ? 0 : round_dimension(untrusted_width.to_f)
      height = untrusted_height == :auto ? 0 : round_dimension(untrusted_height.to_f)

      check_dimensions!(width, height)
      [width, height]
    end

    def check_dimensions!(width, height)
      raise WidthOutOfBounds     if width  < 0 || width  > 9999
      raise HeightOutOfBounds    if height < 0 || height > 9999
      raise NoConcreteDimensions if width + height == 0
    end

    def multiply_dimensions(width, height, ratio)
      [round_dimension(width * ratio), round_dimension(height * ratio)]
    end

    # Standardize how dimensions are rounded in PhotoCook
    def round_dimension(x)
      (x + 0.5).floor
    end

    # Returns Imagemagick dimension-string
    def literal_dimensions(width, height)
      "#{width if width != 0}x#{height if height != 0}"
    end
  end

  class WidthOutOfBounds < ArgumentError
    def initialize
      super 'Width must be positive integer number (0...9999)'
    end
  end

  class HeightOutOfBounds < ArgumentError
    def initialize
      super 'Height must be positive integer number (0...9999)'
    end
  end

  class NoConcreteDimensions < ArgumentError
    def initialize
      super 'Both width and height specified as :auto'
    end
  end
  extend Dimensions
end
