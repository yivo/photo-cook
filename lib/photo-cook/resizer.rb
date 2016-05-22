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

      photo.resize "#{literal_dimensions(width, height)}>"

      store(photo, store_path)
    end

    # Resize the photo to fit within the specified dimensions:
    # - new dimensions will be the same as specified
    # - the photo will be cropped if necessary
    #
    # https://github.com/carrierwaveuploader/carrierwave/blob/71cb18bba4a2078524d1ea683f267d3a97aa9bc8/lib/carrierwave/processing/mini_magick.rb#L176
    def resize_to_fill(source_path, store_path, rw, rh, pixel_ratio)

      # Do nothing if photo is not valid so exceptions will be not thrown
      return unless (photo = open(source_path)) && photo.valid?

      ow, oh = photo[:dimensions]
      mw, mh = multiply_dimensions(rw, rh, pixel_ratio)
      fw, fh = mw, mh

      # ow   oh     rw  rh        mw  mh          fw  fh
      # 1000x800 => 640x640@1x   (640x640)     => 640x640
      # 1000x800 => 640x640@2x   (1280x1280)   => 800x800
      # 1000x800 => 640x640@3x   (3840x3840)   => 800x800
      # 1000x800 => 1280x1280@1x (1280x1280)   => 1280x1280
      # 1000x800 => 1000x1280@1x (1000x1280)   => 1000x1280
      # 1000x800 => 1000x1280@2x (2000x2560)   => 1000x1280
      # 1000x800 => 1500x2000@2x (3000x4000)   => 1000x1333
      # 264x175  => 200x150@2x   (400x300)     => 264x198
      # 331x227  => 340x180@2x   (680x360)     => 331x175
      # 259x179  => 260x180@1x   (260x180)     => 259x179
      # 259x179  => 260x180@2x   (520x360)     => 259x179

      # pixel_ratio > 1 &&
      if ow < mw
        fw = ow
        fh = ((ow * rh) / rw).round
      end

      photo.combine_options do |cmd|
        if fw != ow || fh != oh
          scale_x = fw / ow.to_f
          scale_y = fh / oh.to_f
          if scale_x >= scale_y
            ow = (scale_x * (ow + 0.5)).round
            oh = (scale_x * (oh + 0.5)).round
            cmd.resize "#{ow}>"
          else
            ow = (scale_y * (ow + 0.5)).round
            oh = (scale_y * (oh + 0.5)).round
            cmd.resize "x#{oh}>"
          end
        end

        cmd.gravity CENTER_GRAVITY
        cmd.background TRANSPARENT_BACKGROUND
        if ow != fw || oh != fh
          cmd.extent "#{literal_dimensions(fw, fh)}>"
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