module PhotoCook
  module Assemble

    # Edit URI so it will point to PhotoCook::Middleware
    # NOTE: This method performs no validation
    def assemble_uri(uri, width, height, pixel_ratio, crop)
        result = File.join cache_dir, dirname_or_blank(uri),
                           assemble_command(width, height, pixel_ratio, crop), File.basename(uri)
        uri.start_with?('/') ? '/' + result : result
    end

    # Edit path so it will point to place where resized photo stored
    # NOTE: This method performs no validation
    def assemble_store_path(path, width, height, pixel_ratio, crop)
      rootless = path.split(File.join(root, public_dir)).second
      File.join root, public_dir,
                cache_dir, dirname_or_blank(rootless),
                assemble_command(width, height, pixel_ratio, crop), File.basename(path)
    end

  private
    def dirname_or_blank(path)
      (dirname = File.dirname(path)) == '.' ? '' : dirname
    end
  end
  extend Assemble
end