module PhotoCook
  module Assemble
    mattr_writer :public_dir
    mattr_writer :resize_dir

    def public_dir
      @public_dir || 'public'
    end

    def resize_dir
      @resize_dir || 'resized'
    end

    def assemble_path(path, width, height, options = {})
      File.join(assemble_dir(path), assemble_name(path, width, height, options))
    end

    def assemble_dir(path)
      File.join(File.dirname(path), resize_dir)
    end

    def assemble_name(path, width, height, options = {})
      File.basename(path, '.*') + assemble_command(width, height, options) + File.extname(path)
    end

    def assemble_command(width, height, options = {})
      width, height = PhotoCook.parse_and_check_dimensions(width, height)
      crop, ratio   = PhotoCook.parse_and_check_options(options)
      width, height = PhotoCook.multiply_and_round_dimensions(ratio, width, height)
      "-#{PhotoCook.literal_dimensions(width, height)}#{'crop' if crop}"
    end

    alias resize assemble_path

    def hresize(path, width, options = {})
      assemble_path(path, width, :auto, options)
    end

    def vresize(path, height, options = {})
      assemble_path(path, :auto, height, options)
    end
  end
  extend Assemble
end