module PhotoCook
  module API
    module Magick
      # Performs photo resizing with ImageMagick:
      #   perform_resize('/application/public/uploads/car.png', '/application/public/resized_car.png', 280, 280)
      #
      # Source file: /application/public/uploads/car.png
      # Result file: /application/public/resized_car.png
      #
      # NOTE: This method will perform validation
      def perform_resize(source_path, store_path, width, height, options = {})
        started           = Time.now

        width, height     = parse_and_check_dimensions(width, height)
        pixel_ratio, crop = open_options(options)
                                                                          # Explicit     # Default
        pixel_ratio       = unify_pixel_ratio(parse_and_check_pixel_ratio(pixel_ratio || 1))
        photo             = Resizer.instance.resize(source_path, store_path, width, height, pixel_ratio, !!crop)

        finished          = Time.now
        logger.performed_resize(photo, width, height, pixel_ratio, !!crop, (finished - started) * 1000.0)
        photo
      end
    end

    module URI
      # Builds URI which points to PhotoCook::Middleware:
      #   resize('/uploads/car.png', 280, 280, pixel_ratio: 2.5)
      #     => /uploads/resized/width=280&height=280&pixel_ratio=3&crop=no/car.png
      #
      # NOTE: This method will perform validation
      def resize(uri, width, height, options = {})
        width, height     = parse_and_check_dimensions(width, height)
        pixel_ratio, crop = open_options(options)
                                                        # Explicit     # From cookies                  # Default
        pixel_ratio       = parse_and_check_pixel_ratio(pixel_ratio || PhotoCook.client_pixel_ratio || 1)
        assemble_resize_uri(uri, width, height, unify_pixel_ratio(pixel_ratio), !!crop)
      end

      # Inverse of PhotoCook#resize (see ^):
      #   strip('/uploads/resized/width=280&height=280&pixel_ratio=3&crop=no/car.png')
      #     => /uploads/car.png
      #
      # NOTE: This method will perform validation
      def strip(uri, check = false)
        # TODO Implement check
        disassemble_resize_uri(uri)
      end

      # Shorthand: hresize('/uploads/car.png', 280) <=> resize('/uploads/car.png', 280, nil)
      #
      # NOTE: This method will perform validation
      def hresize(uri, width, options = {})
        resize(uri, width, :auto, options)
      end

      # Shorthand: vresize('/uploads/car.png', 280) <=> resize('/uploads/car.png', nil, 280)
      def vresize(uri, height, options = {})
        resize(uri, :auto, height, options)
      end

      def resize_uri?(uri)
        sections = uri.split('/')

        # Check if PhotoCook cache directory exists:
        #   sections[-3] => resized
        sections[-3] == cache_dir &&

        # Check if valid resize command exists:
        #   sections[-2] => width=auto&height=640&pixel_ratio=1&crop=yes
        (sections[-2] =~ command_regex) == 0
      end
    end

    module Tools
      def open_options(options)
        case options
          when Hash
            [options[:pixel_ratio], options.fetch(:crop, false)]
          when Symbol
            [nil, options == :crop]
          else
            [nil, !!options]
        end
      end

      private :open_options
    end
  end

  extend API::Magick
  extend API::URI
  extend API::Tools
end