module PhotoCook
  class CarrierWave

    def resize(width, height, crop = false)
      prefix = PhotoCook.assemble_prefix width, height, crop
      File.join File.dirname(url), PhotoCook.resize_dir_name, "#{prefix}#{File.basename(url)}"
    end

  end
end