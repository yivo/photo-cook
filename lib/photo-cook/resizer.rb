module PhotoCook
  def self.resizer
    Resizer.instance
  end

  class Resizer
    include Singleton

    CENTER_GRAVITY          = 'Center'.freeze
    TRANSPARENT_BACKGROUND  = 'rgba(255,255,255,0.0)'.freeze

    def resize(src_path, store_path, w, h, px_ratio = 1, crop = false)
      if crop
        resize_to_fill(src_path, store_path, w, h, px_ratio)
      else
        resize_to_fit(src_path, store_path, w, h, px_ratio)
      end
    end

    # Resize the photo to fit within the specified dimensions:
    # - the original aspect ratio will be kept
    # - new dimensions will be not larger then the specified
    #
    # https://github.com/carrierwaveuploader/carrierwave/blob/71cb18bba4a2078524d1ea683f267d3a97aa9bc8/lib/carrierwave/processing/mini_magick.rb#L131
    def resize_to_fit(source_path, store_path, width, height, pixel_ratio)

      # Do nothing if photo is not valid so exceptions will be not thrown
      return unless (photo = open(source_path)) && photo.valid?

      width, height = multiply_dimensions(width, height, pixel_ratio)

      photo.combine_options { |cmd| cmd.resize "#{literal_dimensions(width, height)}>" }

      store(photo, store_path)
    end

    # Resize the photo to fit within the specified dimensions:
    # - new dimensions will be the same as specified
    # - the photo will be cropped if necessary
    #
    # https://github.com/carrierwaveuploader/carrierwave/blob/71cb18bba4a2078524d1ea683f267d3a97aa9bc8/lib/carrierwave/processing/mini_magick.rb#L176
    def resize_to_fill(source_path, store_path, width, height, pixel_ratio)

      # Do nothing if photo is not valid so exceptions will be not thrown
      return unless (photo = open(source_path)) && photo.valid?

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

    def open(source_path)
      begin
        # MiniMagick::Image.open creates a temporary file for us and protects original
        photo = MagickPhoto.open(source_path)
        photo.source_path = source_path
        photo
      rescue
        nil
      end
    end

    def store(resized_photo, store_path)
      FileUtils.mkdir_p(File.dirname(store_path))
      resized_photo.write(store_path)
      resized_photo.resized_path = store_path
      resized_photo
    end

    def literal_dimensions(width, height)
      "#{width if width != 0}x#{height if height != 0}"
    end

    def multiply_dimensions(width, height, ratio)
      [(width * ratio).round, (height * ratio).round]
    end
  end
end