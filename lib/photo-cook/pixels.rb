# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  module Pixels
    MAX = 4256.freeze

    class << self
      def parse(x)
        round(typecast(x))
      end

      def parse!(x)
        check!(x = parse(x))
        x
      end

      def check!(x, ensure_in_bounds = true)
        x = typecast(x)
        raise Invalid,     x if !x.kind_of?(Integer) && (x.nan? || x.infinite?)
        raise OutOfBounds, x if ensure_in_bounds && !in_bounds?(x)
        true
      end

      def in_bounds?(x)
        x = typecast(x)
        0 < x && x <= MAX
      end

      # Standardize how dimensions are rounded in PhotoCook
      def round(x)
        x.floor
      end

      # Returns Imagemagick dimension-string
      def to_magick_dimensions(width, height)
        "#{width}x#{height}"
      end

      def typecast(x)
        x.kind_of?(Numeric) ? x : x.to_f
      end
    end

    class OutOfBounds < ArgumentError
      def initialize(*)
        super 'Size must be positive number (integer or float) ' +
              "which satisfies 0 < x <= #{MAX}"
      end
    end

    class Invalid < ArgumentError
      def initialize(*)
        super 'Size is invalid (NaN) or infinite number'
      end
    end
  end
end

class Float
  def round_pixels
    PhotoCook::Pixels.round(self)
  end
end

class Fixnum
  def round_pixels
    self
  end
end
