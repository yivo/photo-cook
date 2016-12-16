# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  module Resize
    class << self
      def resizer
        Resizer.instance
      end
    end

    class Resizer
      include Singleton

      CENTER_GRAVITY          = 'Center'.freeze
      TRANSPARENT_BACKGROUND  = 'rgba(255, 255, 255, 0.0)'.freeze

      def resize(source_path, store_path, w, h, mode)
        send("resize_to_#{mode}", source_path, store_path, w, h)
      end

      # Resize the photo to fit within the specified dimensions:
      # - the original aspect ratio will be kept
      # - new dimensions will be not larger then the specified
      def resize_to_fit(source_path, store_path, width, height)
        process photo: source_path, store: store_path do |photo|
          outw, outh = Calculations.size_to_fit(*photo[:dimensions], width, height)
          photo.resize "#{PhotoCook::Pixels.to_magick_dimensions(outw, outh)}>"

          photo.resize_mode       = :fit
          photo.desired_width     = width
          photo.desired_height    = height
          photo.calculated_width  = outw
          photo.calculated_height = outh
        end
      end

      # Resize the photo to fill within the specified dimensions:
      # - the original aspect ratio will be kept
      # - new dimensions may vary
      def resize_to_fill(source_path, store_path, width, height)
        process photo: source_path, store: store_path do |photo|
          outw, outh = Calculations.size_to_fill(*photo[:dimensions], width, height)

          photo.combine_options do |cmd|
            cmd.resize     PhotoCook::Pixels.to_magick_dimensions(outw, outh) + '^'
            cmd.gravity    CENTER_GRAVITY
            cmd.background TRANSPARENT_BACKGROUND
            cmd.crop       PhotoCook::Pixels.to_magick_dimensions(outw, outh)  + '+0+0'
            cmd.repage.+
          end

          photo.resize_mode       = :fill
          photo.desired_width     = width
          photo.desired_height    = height
          photo.calculated_width  = outw
          photo.calculated_height = outh
        end
      end

    protected

      def process(photo:, store:)
        photo = open(photo)
        yield(photo)
        store(photo, store)
      end

      def open(source_path)
        # MiniMagick::Image.open creates a temporary file for us and protects original
        photo = MagickPhoto.open(source_path)
        photo.validate!
        photo.source_path = source_path
        photo
      end

      def store(resized_photo, store_path)
        path_to_dir = File.dirname(store_path)

        # Solution to broken symlinks.
        # This added here because mkdir -p can't detect broken symlinks.
        FileUtils.rm(path_to_dir) if !Dir.exists?(path_to_dir) && File.symlink?(path_to_dir)
        FileUtils.mkdir_p(path_to_dir)
        resized_photo.write(store_path)
        resized_photo.store_path = store_path
        resized_photo
      end
    end
  end
end
