require 'mini_magick'

module PhotoCook
  class Resizer
    include Singleton

    CENTER_GRAVITY          = 'Center'.freeze
    TRANSPARENT_BACKGROUND  = 'rgba(255,255,255,0.0)'.freeze

    def resize(photo_path, width, height, crop = false)
      if crop
        resize_to_fill photo_path, width, height
      else
        resize_to_fit photo_path, width, height
      end
    end

    # Resize the photo to fit within the specified dimensions:
    # - the original aspect ratio will be kept
    # - new dimensions will be not larger then the specified
    #
    # https://github.com/carrierwaveuploader/carrierwave/blob/71cb18bba4a2078524d1ea683f267d3a97aa9bc8/lib/carrierwave/processing/mini_magick.rb#L131
    def resize_to_fit(photo_path, width, height)

      # Do nothing if photo is not valid so exceptions will be not thrown
      return unless (photo = open(photo_path)).try(:valid?)

      width, height = parse_dimensions(width, height)
      store_path    = PhotoCook.assemble_path(photo_path, width, height, false)

      if width > 0 || height > 0
        photo.combine_options do |cmd|
          cmd.resize "#{width == 0 ? nil : width}x#{height == 0 ? nil : height}>"
        end
      end

      store(photo, store_path)
    end

    # Resize the photo to fit within the specified dimensions:
    # - new dimensions will be the same as specified
    # - the photo will be cropped if necessary
    #
    # https://github.com/carrierwaveuploader/carrierwave/blob/71cb18bba4a2078524d1ea683f267d3a97aa9bc8/lib/carrierwave/processing/mini_magick.rb#L176
    def resize_to_fill(photo_path, width, height)

      # Do nothing if photo is not valid so exceptions will be not thrown
      return unless (photo = open(photo_path)).try(:valid?)

      width, height = parse_dimensions(width, height)
      cols,  rows   = photo[:dimensions]
      store_path    = PhotoCook.assemble_path(photo_path, width, height, true)

      if width > 0 || height > 0
        photo.combine_options do |cmd|
          if width != cols || height != rows
            scale_x = width / cols.to_f
            scale_y = height / rows.to_f
            if scale_x >= scale_y
              cols = (scale_x * (cols + 0.5)).round
              rows = (scale_x * (rows + 0.5)).round
              cmd.resize "#{cols}>"
            else
              cols = (scale_y * (cols + 0.5)).round
              rows = (scale_y * (rows + 0.5)).round
              cmd.resize "x#{rows}>"
            end
          end
          cmd.gravity CENTER_GRAVITY
          cmd.background TRANSPARENT_BACKGROUND
          if cols != width || rows != height
            cmd.extent "#{width == 0 ? nil : width}x#{height == 0 ? nil : height}>"
          end
        end
      end

      store(photo, store_path)
    end

  protected

    def open(photo_path)
      begin
        # MiniMagick::Image.open creates a temporary file for us and protects original
        photo = MagickPhoto.open(photo_path)
        photo.source_path = photo_path
        photo
      rescue
        nil
      end
    end

    def store(resized_photo, path_to_store_at)
      dir = File.dirname path_to_store_at
      Dir.mkdir dir unless File.exists?(dir)
      resized_photo.write path_to_store_at
      resized_photo.resized_path = path_to_store_at
      resized_photo
    end

    def parse_dimensions(width, height)
      width   = width == :auto ? 0 : width.to_i
      height  = height == :auto ? 0 : height.to_i
      check_dimensions!(width, height)
      [width, height]
    end

    def check_dimensions!(width, height)
      raise ArgumentError, 'Expected positive numbers ' if width < 0 || height < 0
    end
  end
end