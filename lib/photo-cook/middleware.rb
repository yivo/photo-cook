# To use this middleware you should configure application:
# application.config.middleware.insert_before(Rack::Sendfile, PhotoCook::Middleware, Rails.root)

module PhotoCook
  class Middleware

    def initialize(app, root)
      @app, @root = app, root
    end

    # The example will be concentrated around uri:
    # /uploads/photos/resized/car-640x320crop.png
    # /resized/uploads/photos1/width:auto&height:640&crop:true&pixel-ratio:1/car.png

    def call(env)
      uri = extract_uri(env)

      return default_actions(env) if

        # Check if uri starts with:
        #   /resized
        false == uri.start_with?(PhotoCook.resize_uri_indicator) ||

        # Check if uri has valid resize command:
        #   width:auto&height:640&crop:true&pixel-ratio:1
        nil   == uri.split(File::SEPARATOR)[-2]=~(PhotoCook.command_regex) ||

        # If for some reasons file exists but request went to Ruby app
        requested_file_exists?(uri)

      # At this point we are sure that this request is targeting to resize photo

      # Assemble path of the source photo
      source_path = assemble_source_path(uri)

      # Matched data: width:auto&height:640&crop:true&pixel-ratio:1
      command = Regexp.last_match

      # Finally resize photo
      # Resized photo will appear in resize directory
      photo = PhotoCook.actually_resize(source_path, command[:width], command[:height], command[:pixel_ratio], command[:crop])

      if photo
        PhotoCook.on_resize(photo, command)
        respond_with_file(env)
      else
        default_actions(env)
      end
    end

  private

    def assemble_source_path(resize_uri)
      # Take URI:
      # /resized/uploads/photos1/width:auto&height:640&crop:true&pixel-ratio:1/car.png
      #
      # Split by file separator:
      # ["", "resized", "uploads", "photos", "1", "width:auto&height:640&crop:true&pixel-ratio:1", "car.png"]
      #
      els = resize_uri.split(File::SEPARATOR)

      # Delete PhotoCook directory:
      # ["", "uploads", "photos", "1", "width:auto&height:640&crop:true&pixel-ratio:1", "car.png"]
      els.delete_at(1)

      # Delete command string:
      # ["", "uploads", "photos", "1", "car.png"]
      els.delete_at(-2)

      URI.decode File.join(@root, PhotoCook.public_dir, els)
    end

    def requested_file_exists?(uri)
      # Check if file exists:
      # /application/public/resized/uploads/photos/1/width:auto&height:640&crop:true&pixel-ratio:1/car.png
      File.exists? File.join(@root, PhotoCook.public_dir, uri)
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
      status, headers, body = Rack::File.new(File.join(@root, PhotoCook.public_dir)).call(env)
      response = Rack::Response.new(body, status, headers)
      response.finish
    end
  end
end