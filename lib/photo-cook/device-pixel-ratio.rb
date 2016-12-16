# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  module DevicePixelRatio
    DEFAULT = 1.0.freeze
    MAX     = 4.0.freeze

    class << self
      def parse(x)
        typecast(x)
      end

      def parse!(x)
        check!(x = parse(x))
        x
      end

      def check!(x)
        x = typecast(x)
        raise Invalid,     x if !x.kind_of?(Integer) && (x.nan? || x.infinite?)
        raise OutOfBounds, x if x < DEFAULT || x > MAX
        true
      end

      # Do not produce various number of pixel ratios:
      #   1.0 => 1
      #   2.5 => 3
      #   2.1 => 3
      #   3.1 => 4
      def unify(x)
        typecast(x).ceil
      end

      def valid?(x)
        check!(x)
      rescue Invalid, OutOfBounds
        false
      end

      def typecast(x)
        x.kind_of?(Numeric) ? x : x.to_f
      end
    end

    class Invalid < ArgumentError
      def initialize(*)
        super 'Device pixel ratio is invalid (NaN) or infinite number'
      end
    end

    class OutOfBounds < ArgumentError
      def initialize(*)
        super 'Device pixel ratio must be positive number (integer or float) ' +
              "which satisfies #{DEFAULT} <= x <= #{MAX}"
      end
    end
  end

  class << self
    def device_pixel_ratio
      @device_pixel_ratio || DevicePixelRatio::DEFAULT
    end

    def device_pixel_ratio=(x)
      @device_pixel_ratio = DevicePixelRatio.parse!(x)
    end
  end
end
