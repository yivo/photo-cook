module PhotoCook
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

      # Do nothing if photo is not valid so exceptions will be not thrown
      photo = open(source_path)
      return photo unless photo && photo.valid?

      photo.resize "#{PhotoCook.literal_dimensions(width, height)}>"

      store(photo, store_path)
    end

    # Resize the photo to fit within the specified dimensions:
    # - new dimensions will be the same as specified
    # - the photo will be cropped if necessary
    def resize_to_fill(source_path, store_path, width, height)

      # Do nothing if photo is not valid so exceptions will be not thrown
      photo = open(source_path)
      return photo unless photo && photo.valid?

      outw, outh = PhotoCook.size_to_fill(*photo[:dimensions], width, height)

      photo.combine_options do |cmd|
        cmd.resize     PhotoCook.literal_dimensions(outw, outh) + '^'
        cmd.gravity    CENTER_GRAVITY
        cmd.background TRANSPARENT_BACKGROUND
        cmd.crop       PhotoCook.literal_dimensions(outw, outh) + '+0+0'
        cmd.repage.+
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
  end
end
