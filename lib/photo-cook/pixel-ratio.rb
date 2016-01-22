module PhotoCook
  module PixelRatio
    def parse_and_check_pixel_ratio(unsafe_ratio)
      pixel_ratio = unsafe_ratio.to_f

      raise PixelRatioInvalidOrInfinite if pixel_ratio.nan? || pixel_ratio.infinite?
      raise PixelRatioOutOfBounds       if pixel_ratio < 1 || pixel_ratio > 4

      pixel_ratio
    end

    def valid_pixel_ratio?(ratio)
      !ratio.nan? && !ratio.infinite? && ratio >= 1 && ratio <= 4
    end

    # Do not produce various number of pixel ratios:
    #   2.5 => 3
    #   2.1 => 3
    def unify_pixel_ratio(px_ratio)
      px_ratio.ceil
    end

    def pixel_ratio
      unify_pixel_ratio(client_pixel_ratio || 1.0)
    end
  end

  class PixelRatioInvalidOrInfinite < ArgumentError
    def initialize
      super 'Given pixel ratio is invalid number or infinite'
    end
  end

  class PixelRatioOutOfBounds < ArgumentError
    def initialize
      super 'Pixel ratio must be positive number: 1 <= pixel_ratio <= 4'
    end
  end
  extend PixelRatio
end