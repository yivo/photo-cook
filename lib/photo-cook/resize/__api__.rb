# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  module Resize
    class << self
      attr_accessor :cache_dir
      attr_accessor :multiplier
    end
    self.cache_dir  = 'resize-cache'
    self.multiplier = DevicePixelRatio::DEFAULT

    class << self
      # Performs photo resizing with ImageMagick:
      #   perform_resize('/application/public/uploads/car.png', '/application/public/resized_car.png', 280, 280)
      #
      # Source file: /application/public/uploads/car.png
      # Result file: /application/public/resized_car.png
      #
      # NOTE: This method will perform validation
      # NOTE: This method knows anything about resize cache
      def perform(source_path, store_path, w, h, mode)
        w, h, mode  = parse_options(w, h, mode, multiplier: 1.0)
        photo, msec = PhotoCook::Utils.measure do
          resizer.resize(source_path, store_path, w, h, mode)
        end
        PhotoCook.notify('resize', photo, msec)
        photo
      end

      # Builds URI which points to PhotoCook::Middleware:
      #   uri('/uploads/car.png', 280, 280)
      #     => /uploads/resize-cache/fit-280x280/car.png
      #
      # NOTE: This method will perform validation
      def uri(uri, width, height, mode, options = {})
        Assemble.assemble_resize_uri(uri, *parse_options(width, height, mode, options, false))
      end

      # Inverse of PhotoCook#resize (see ^):
      #   strip('/uploads/resize-cache/fit-280x280/car.png')
      #     => /uploads/car.png
      #
      # NOTE: This method will perform validation
      def strip(uri, check = false)
        # TODO Implement check
        Assemble.disassemble_resize_uri(uri)
      end

      # TODO Change uri to source_path
      def base64_uri(uri, width, height, mode, options = {})
        w, h, m     = parse_options(width, height, mode, options)
        command     = Command.assemble(w, h, m)
        source_path = Assemble.assemble_source_path_from_normal_uri(PhotoCook.root_path, uri)
        store_path  = Assemble.assemble_store_path(PhotoCook.root_path, source_path, command)
        photo       = if File.readable?(store_path)
          MagickPhoto.new(store_path)
        else
          Resize.perform(source_path, store_path, w, h, m)
        end

        "data:#{photo.mime_type};base64,#{Base64.strict_encode64(File.read(photo.path))}"
      end

      def base64_uri_from_source_path(source_path, store_path, width, height, mode, options = {})
        w, h, m = parse_options(width, height, mode, options)
        photo   = if File.readable?(store_path)
          MagickPhoto.new(store_path)
        else
          Resize.perform(source_path, store_path, w, h, m)
        end

        "data:#{photo.mime_type};base64,#{Base64.strict_encode64(File.read(photo.path))}"
      end

      # TODO Think about it. This can be very cool feature of PhotoCook
      if defined?(Rails)
        def static_asset_uri(uri, *rest)
          # If production assets are precompiled and placed into public so we can resize as usually
          Rails.application.config.serve_static_files ? uri : uri(uri, *rest)
        end
      end

      def parse_options(width, height, mode, options, check_pixels_in_bounds = true)
        multiplier  = options.fetch(:multiplier, self.multiplier).to_f
        mode        = Mode.parse!(mode)
        width       = Pixels.round(Pixels.parse(width)  * multiplier)
        height      = Pixels.round(Pixels.parse(height) * multiplier)
        Pixels.check!(width, check_pixels_in_bounds)
        Pixels.check!(height, check_pixels_in_bounds)
        [width, height, mode]
      end
    end
  end
end
