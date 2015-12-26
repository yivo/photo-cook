module PhotoCook
  module Resizing

    # Performs photo resizing:
    #   resize_photo('/application/public/uploads/car.png', 280, 280)
    #
    # NOTE: This method will perform validation
    def resize_photo(path, width, height, options = {})
      started           = Time.now

      width, height     = parse_and_check_dimensions(width, height)
      pixel_ratio, crop = open_options(options)
                                                      # Explicit     # Default
      pixel_ratio       = unify_pixel_ratio(parse_and_check_pixel_ratio(pixel_ratio || 1))
      photo             = Resizer.instance.resize(path, width, height, pixel_ratio, !!crop)

      finished          = Time.now
      log_resize(photo, width, height, pixel_ratio, !!crop, (finished - started) * 1000.0)
      photo
    end

    # Builds URI for resizing:
    #   resize('/uploads/car.png', 280, 280, pixel_ratio: 2.5)
    #     => /resized/uploads/width:280&height:280&crop:0&pixel_ratio:3
    #
    # NOTE: This method will perform validation
    def build_resize_uri(uri, width, height, options = {})
      width, height     = parse_and_check_dimensions(width, height)
      pixel_ratio, crop = open_options(options)
                                                      # Explicit     # From cookies                  # Default
      pixel_ratio       = parse_and_check_pixel_ratio(pixel_ratio || PhotoCook.client_pixel_ratio || 1)
      assemble_uri(uri, width, height, unify_pixel_ratio(pixel_ratio), !!crop)
    end

    alias resize build_resize_uri

    # Shorthand: hresize('/uploads/car.png', 280) <=> resize('/uploads/car.png', 280, nil)
    def hresize(uri, width, options = {})
      resize(uri, width, :auto, options)
    end

    # Shorthand: vresize('/uploads/car.png', 280) <=> resize('/uploads/car.png', nil, 280)
    def vresize(uri, height, options = {})
      resize(uri, :auto, height, options)
    end

  private
    def open_options(options)
      case options
        when Hash
          [options[:pixel_ratio], options.fetch(:crop, false)]
        when Symbol
          [nil, options == :crop]
        else
          [nil, nil]
      end
    end

    # Do not produce various number of pixel ratios:
    #   2.5 => 3
    #   2.1 => 3
    def unify_pixel_ratio(px_ratio)
      px_ratio.ceil
    end
  end

  extend Resizing
end