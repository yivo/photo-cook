module PhotoCook
  module Dimensions
    def parse_and_check_dimensions(unsafe_width, unsafe_height)
      width  = unsafe_width  == :auto ? 0 : unsafe_width.to_i
      height = unsafe_height == :auto ? 0 : unsafe_height.to_i

      check_dimensions!(width, height)
      [width, height]
    end

    def check_dimensions!(width, height)
      raise WidthOutOfBounds     if width  < 0 || width  > 9999
      raise HeightOutOfBounds    if height < 0 || height > 9999
      raise NoConcreteDimensions if width + height == 0
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