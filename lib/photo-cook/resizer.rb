module PhotoCook
  class Resizer
    include Singleton

    CENTER_GRAVITY = 'Center'
    TRANSPARENT_BACKGROUND = 'rgba(255,255,255,0.0)'
    PHOTO_QUALITY = 100

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
    def resize_to_fit(photo_path, width, height)
      # Do nothing if photo is not valid so exceptions will be not thrown
      return unless (photo = open(photo_path)).try(:valid?)
      photo.combine_options do |cmd|
        cmd.quality PHOTO_QUALITY
        cmd.resize "#{width}x#{height}"
      end
      store photo, PhotoCook.assemble_path(photo_path, width, height, false)
    end

    # Resize the photo to fit within the specified dimensions:
    # - new dimensions will be the same as specified
    # - the photo will be cropped if necessary
    def resize_to_fill(photo_path, width, height)
      # Do nothing if photo is not valid so exceptions will be not thrown
      return unless (photo = open(photo_path)).try(:valid?)

      cols, rows = photo[:dimensions]
      photo.combine_options do |cmd|
        if width != cols || height != rows
          scale_x = width / cols.to_f
          scale_y = height / rows.to_f
          if scale_x >= scale_y
            cols = (scale_x * (cols + 0.5)).round
            rows = (scale_x * (rows + 0.5)).round
            cmd.resize "#{cols}"
          else
            cols = (scale_y * (cols + 0.5)).round
            rows = (scale_y * (rows + 0.5)).round
            cmd.resize "x#{rows}"
          end
        end
        cmd.gravity CENTER_GRAVITY
        cmd.background TRANSPARENT_BACKGROUND
        cmd.quality PHOTO_QUALITY
        cmd.extent "#{width}x#{height}" if cols != width || rows != height
      end

      store photo, PhotoCook.assemble_path(photo_path, width, height, true)
    end

    private

    def open(photo_path)
      begin
        ::MiniMagick::Image.open(photo_path)
      rescue
        nil
      end
    end

    def store(resized_photo, path_to_store_at)
      dir = File.dirname path_to_store_at
      Dir.mkdir dir unless File.exists?(dir)
      resized_photo.write path_to_store_at
      resized_photo
    end

  end
end