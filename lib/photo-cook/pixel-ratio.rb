module PhotoCook
  module PixelRatio
    def parse_and_check_pixel_ratio(unsafe_ratio)
      pixel_ratio = unsafe_ratio.to_f

      raise PixelRatioInvalidOrInfiniteError if pixel_ratio.nan? || pixel_ratio.infinite?
      raise PixelRatioOutOfBoundsError       if pixel_ratio < 1 || pixel_ratio > 4

      pixel_ratio
    end

    def valid_pixel_ratio?(ratio)
      !ratio.nan? && !ratio.infinite? && ratio >= 1 && ratio <= 4
    end
  end

  class PixelRatioInvalidOrInfiniteError < ArgumentError
    def initialize
      super 'Given pixel ratio is invalid number or infinite'
    end
  end

  class PixelRatioOutOfBoundsError < ArgumentError
    def initialize
      super 'Pixel ratio must be positive number: 1 <= pixel_ratio <= 4'
    end
  end
  extend PixelRatio
end