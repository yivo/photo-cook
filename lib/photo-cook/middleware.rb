# To use this middleware you should configure application:
#   application.config.middleware.insert_before(Rack::Sendfile, PhotoCook::Middleware, Rails.root)

module PhotoCook
  class Middleware

    def initialize(app, root)
      @app, @root = app, root
    end

    # Consider we have car.png in /uploads/photos/1/car.png
    # We want to resize it with the following params:
    #   Width:       choose automatically
    #   Height:      exactly 640px
    #   Mode:        fill
    #
    # Middleware will handle this URI:
    #   /uploads/photos/1/resized/width=auto&height=640&mode=fill/car.png
    #
    def call(env)
      uri = extract_uri(env)

      return default_actions(env) if

        # Check if URI contains PhotoCook resize indicators
        PhotoCook.resize_uri?(uri) == false ||

        # If for some reasons file exists but request went to Ruby app
        requested_file_exists?(uri)

      # At this point we are sure that this request is targeting to resize photo
      PhotoCook.notify(:matched_resize_uri, uri)

      # Matched data: width=auto&height=640&mode=fill
      command = PhotoCook.extract_command(uri)

      # Assemble path of the source photo:
      #   => /application/public/uploads/photos/1/car.png
      source_path = PhotoCook.assemble_source_path_from_resize_uri(@root, uri)

      # Assemble path of the resized photo:
      #   => /application/public/resized/uploads/photos/1/COMMAND/car.png
      store_path = PhotoCook.assemble_store_path(@root, source_path, command.to_s)

      if File.exists?(store_path)
        PhotoCook.symlink_cache_dir(source_path, store_path)
        default_actions(env)

      else
        # Finally resize photo
        # Resized photo will appear in resize directory
        photo = PhotoCook.perform_resize(source_path, store_path, command[:width], command[:height], command[:mode])
        
        if photo
          PhotoCook.symlink_cache_dir(source_path, store_path)
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
      #   /application/public/uploads/photos/1/resized/width=auto&height=640&mode=fill/car.png
      File.exists?(File.join(public, uri))
    end

    def extract_uri(env)
      Rack::Utils.clean_path_info(Rack::Utils.unescape(env['PATH_INFO']))
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
  end
end
