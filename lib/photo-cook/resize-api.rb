module PhotoCook
  class << self
    # Performs photo resizing with ImageMagick:
    #   perform_resize('/application/public/uploads/car.png', '/application/public/resized_car.png', 280, 280)
    #
    # Source file: /application/public/uploads/car.png
    # Result file: /application/public/resized_car.png
    #
    # NOTE: This method will perform validation
    # NOTE: This method knows anything about resize cache
    def perform_resize(source_path, store_path, w, h, mode)
      w, h        = parse_and_check_dimensions(w, h)
      mode        = parse_and_check_mode(mode)

      notify(:will_perform_resize)

      photo, msec = measure { resizer.resize(source_path, store_path, w, h, mode) }

      if photo
        notify(:resize_performed, photo, w, h, mode, msec)
      else
        notify(:resize_not_performed, source_path, store_path, w, h, mode)
      end

      photo
    end

    # Builds URI which points to PhotoCook::Middleware:
    #   resize('/uploads/car.png', 280, 280)
    #     => /uploads/resized/width=280&height=280&mode=fit/car.png
    #
    # NOTE: This method will perform validation
    def resize(uri, width, height, mode = :fit)
      w, h = parse_and_check_dimensions(width, height)
      mode = parse_and_check_mode(mode)
      assemble_resize_uri(uri, w, h, mode)
    end

    # Inverse of PhotoCook#resize (see ^):
    #   strip('/uploads/resized/width=280&height=280&mode=fit/car.png')
    #     => /uploads/car.png
    #
    # NOTE: This method will perform validation
    def strip(uri, check = false)
      # TODO Implement check
      disassemble_resize_uri(uri)
    end

    def base64_uri(uri, width, height, mode = :fit)
      w, h        = parse_and_check_dimensions(width, height)
      mode        = parse_and_check_mode(mode)
      command     = assemble_command(w, h, mode)
      source_path = assemble_source_path_from_normal_uri(root, uri)
      store_path  = assemble_store_path(root, source_path, command)

      photo = if File.exists?(store_path)
        MagickPhoto.new(store_path)
      else
        perform_resize(source_path, store_path, w, h, mode)
      end

      if photo
        "data:#{photo.mime_type};base64,#{Base64.encode64(File.read(photo.path))}"
      end
    end

    def resize_uri?(uri)
      sections = uri.split('/')

      # Check if PhotoCook cache directory exists:
      #   sections[-3] => resized
      sections[-3] == cache_dir &&

      # Check if valid resize command exists:
      #   sections[-2] => width=auto&height=640&mode=fit
      (sections[-2] =~ command_regex) == 0
    end
  end
end
