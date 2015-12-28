# To use this middleware you should configure application:
#   application.config.middleware.insert_before(Rack::Sendfile, PhotoCook::Middleware, Rails.root)

# TODO Extract symlink

module PhotoCook
  class Middleware

    def initialize(app, root)
      @app, @root = app, root
    end

    # Consider we have car.png in /uploads/photos/1/car.png
    # We want to resize it with the following params:
    #   Width:       choose automatically
    #   Height:      exactly 640px
    #   Pixel ratio: 1
    #   Crop:        yes
    #
    # Middleware will handle this URI:
    #   /uploads/photos/1/resized/width=auto&height=640&pixel_ratio=1&crop=yes/car.png
    #
    def call(env)
      uri = extract_uri(env)

      return default_actions(env) if

        # Check if URI contains PhotoCook resize indicators
        PhotoCook.resize_uri?(uri) == false ||

        # If for some reasons file exists but request went to Ruby app
        requested_file_exists?(uri)

      # At this point we are sure that this request is targeting to resize photo

      PhotoCook.logger.matched_resize_uri(uri)

      # Matched data: width=auto&height=640&pixel_ratio=1&crop=yes
      command = PhotoCook.extract_command(uri)

      # Assemble path of the source photo:
      #   => /application/public/uploads/photos/1/car.png
      source_path = PhotoCook.assemble_source_path(@root, uri)

      # Assemble path of the resized photo:
      #   => /application/public/resized/uploads/photos/1/COMMAND/car.png
      store_path  = PhotoCook.assemble_store_path(@root, source_path, command.to_s)

      if File.exists?(store_path)
        symlink_cache_dir(source_path, store_path)
        default_actions(env)

      else
        # Map crop option values: 'yes' => true, 'no' => false
        crop = PhotoCook.decode_crop_option(command[:crop])

        # Finally resize photo
        # Resized photo will appear in resize directory
        photo = PhotoCook.perform_resize(
          source_path, store_path,
          command[:width], command[:height],
          pixel_ratio: command[:pixel_ratio], crop: crop
        )
        if photo
          symlink_cache_dir(source_path, store_path)
          respond_with_file(env)
        else
          default_actions(env)
        end
      end
    end

  private
    def public
      @public ||= PhotoCook.assemble_public_path(@root)
    end

    def requested_file_exists?(uri)
      # Check if file exists:
      #   /application/public/uploads/photos/1/resized/width=auto&height=640&pixel_ratio=1&crop=yes/car.png
      File.exists? File.join(public, uri)
    end

    def extract_uri(env)
      # Remove query string and fragment
      Rack::Utils.unescape(env['PATH_INFO'].gsub(/[\?#].*\z/, ''))
    end

    def default_actions(env)
      @app.call(env)
    end

    def respond_with_file(env)
      # http://rubylogs.com/writing-rails-middleware/
      # https://viget.com/extend/refactoring-patterns-the-rails-middleware-response-handler
      status, headers, body = Rack::File.new(public).call(env)
      response = Rack::Response.new(body, status, headers)
      response.finish
    end

    def symlink_cache_dir(source_path, store_path)
      # /application/public/uploads/photos/1
      p1 = Pathname.new(File.dirname(source_path))

      # /application/public/resized/uploads/photos/1
      p2 = Pathname.new(File.dirname(File.dirname(store_path)))

      # ../../../resized/uploads/photos/1
      relative = p2.relative_path_from(p1)

      # Guess cache directory (must be same as PhotoCook.cache_dir)
      cache_dir = relative.to_s.split(File::SEPARATOR).find { |el| !(el =~ /\A\.\.?\z/) }

      unless Dir.exists?(p1.join(cache_dir))
        ln_flags = PhotoCook.explicitly_add_relative_flag? ? '-rs' : '-s'

        cmd = "cd #{p1} && rm -rf #{cache_dir} && ln #{ln_flags} #{relative} #{cache_dir}"

        PhotoCook.logger.will_symlink_cache_dir(cmd)

        %x{ #{cmd} }

        if $?.success?
          PhotoCook.logger.symlink_cache_dir_success
        else
          PhotoCook.logger.symlink_cache_dir_failure
        end
      end
    end
  end

  def self.explicitly_add_relative_flag?
    if @relative_flag_illegal.nil?
      out = Open3.capture2e('ln', '-rs')[0]
      @relative_flag_illegal = !!(out =~ /\billegal\b/)
    end
    @relative_flag_illegal == false
  end
end