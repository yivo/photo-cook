module PhotoCook
  class Resizer
    include Singleton

    CENTER_GRAVITY          = 'Center'.freeze
    TRANSPARENT_BACKGROUND  = 'rgba(255,255,255,0.0)'.freeze

    def resize(photo_path, width, height, pixel_ratio = 1.0, crop = false)
      if crop
        resize_to_fill(photo_path, width, height, pixel_ratio)
      else
        resize_to_fit(photo_path, width, height, pixel_ratio)
      end
    end

    # Resize the photo to fit within the specified dimensions:
    # - the original aspect ratio will be kept
    # - new dimensions will be not larger then the specified
    #
    # https://github.com/carrierwaveuploader/carrierwave/blob/71cb18bba4a2078524d1ea683f267d3a97aa9bc8/lib/carrierwave/processing/mini_magick.rb#L131
    def resize_to_fit(photo_path, width, height, pixel_ratio)

      # Do nothing if photo is not valid so exceptions will be not thrown
      return unless (photo = open(photo_path)) && photo.valid?

      store_path    = assemble_store_path(photo_path, width, height, pixel_ratio, false)
      width, height = multiply_dimensions(width, height, pixel_ratio)

      photo.combine_options { |cmd| cmd.resize "#{literal_dimensions(width, height)}>" }

      store(photo, store_path)
    end

    # Resize the photo to fit within the specified dimensions:
    # - new dimensions will be the same as specified
    # - the photo will be cropped if necessary
    #
    # https://github.com/carrierwaveuploader/carrierwave/blob/71cb18bba4a2078524d1ea683f267d3a97aa9bc8/lib/carrierwave/processing/mini_magick.rb#L176
    def resize_to_fill(photo_path, width, height, pixel_ratio)

      # Do nothing if photo is not valid so exceptions will be not thrown
      return unless (photo = open(photo_path)) && photo.valid?

      store_path      = assemble_store_path(photo_path, width, height, pixel_ratio, true)
      cols, rows      = photo[:dimensions]
      mwidth, mheight = multiply_dimensions(width, height, pixel_ratio)

      # TODO
      # Original dimensions are 1000x800. You want 640x640@1x. You will get 640x640
      # Original dimensions are 1000x800. You want 640x640@2x. You will get 800x800
      # Original dimensions are 1000x800. You want 640x640@3x. You will get 800x800
      # Original dimensions are 1000x800. You want 1280x1280@1x. You will get ?
      # Original dimensions are 1000x800. You want 1000x1280@1x. You will get ?

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
          cmd.extent "#{literal_dimensions(width, height)}>"
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
      dir = File.dirname(path_to_store_at)
      FileUtils.mkdir_p(dir) unless File.exists?(dir)

      resized_photo.write(path_to_store_at)
      resized_photo.resized_path = path_to_store_at
      resized_photo
    end

    def literal_dimensions(width, height)
      "#{width == 0 ? nil : width}x#{height == 0 ? nil : height}"
    end

    def assemble_store_path(path, width, height, pixel_ratio, crop)
      PhotoCook.assemble_store_path(path, width, height, pixel_ratio, crop)
    end

    def multiply_dimensions(width, height, ratio)
      [(width * ratio).round, (height * ratio).round]
    end
  end
end