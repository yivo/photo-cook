module PhotoCook
  module Assemble

    # Edit URI so it will point to PhotoCook::Middleware
    # NOTE: This method performs no validation
    def assemble_uri(uri, width, height, options = {})
      ('/' if uri.start_with?('/')) +
        File.join(cache_dir, File.dirname(uri),
                  assemble_command(width, height, options), File.basename(uri))
    end

    # Edit path so it will point to place where resized photo stored
    # NOTE: This method performs no validation
    def assemble_store_path(path, width, height, options = {})
      rootless = path.split(File.join(root, public_dir)).second
      File.join root, public_dir,
                cache_dir, File.dirname(rootless),
                assemble_command(width, height, options), File.basename(path)
    end

    def resize(uri, width, height, options = {})
      # TODO Validate args
      assemble_uri(uri, width, height, options)
    end

    def hresize(uri, width, options = {})
      resize(uri, width, :auto, options)
    end

    def vresize(uri, height, options = {})
      resize(uri, :auto, height, options)
    end
  end
  extend Assemble
end