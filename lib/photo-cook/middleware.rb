# To use this middleware you should configure application:
# application.config.middleware.insert_before(Rack::Sendfile, PhotoCook::Middleware, Rails.root)
require 'rack'

module PhotoCook
  class Middleware

    def initialize(app, root)
      @app, @root = app, root
    end

    # The example will be concentrated around uri:
    # /uploads/photos/resized/640x320_crop_car.png
    def call(env)
      uri = extract_uri(env)

      return default_actions(env) unless

        # Lets ensure that directory name matches PhotoCook.resize_dirname
        # dirname = /uploads/photos/resized
        # File::SEPARATOR + PhotoCook.resize_dirname = /resized
        # dirname.chomp! = /uploads/photos
        (dirname = File.dirname(uri)).chomp!(File::SEPARATOR + PhotoCook.resize_dirname) &&

        # Lets ensure that photo_name starts with resize command
        # photo_name = 640x320_crop_car.png
        # photo_name.sub! = car.png
        (photo_name = File.basename(uri)).sub!(command_regex, '')

      return default_actions(env) if requested_file_exists?(uri)

      # Regex match: 640x320_crop_
      command = Regexp.last_match

      # At this point we are sure that this request is targeting to resize photo

      # Lets assemble path of the source photo
      source_path = assemble_source_path(dirname, photo_name)

      # Do nothing if source photo not exists
      # return default unless File.exists?(source) || File.readable?(source)

      # Finally resize photo
      resizer = PhotoCook::Resizer.instance

      # Resizer will store photo in resize directory
      photo = resizer.resize source_path, command[:width].to_i, command[:height].to_i, !!command[:crop]

      if photo
        # http://rubylogs.com/writing-rails-middleware/
        # https://viget.com/extend/refactoring-patterns-the-rails-middleware-response-handler
        status, headers, body = Rack::File.new(File.join(@root, PhotoCook.public_dirname)).call(env)
        response = Rack::Response.new(body, status, headers)
        response.finish
      else
        default_actions(env)
      end
    end

    private

    def assemble_source_path(dirname, photo_name)
      URI.decode File.join(@root, PhotoCook.public_dirname, dirname, photo_name)
    end

    def requested_file_exists?(uri)
      # /my_awesome_project_root/public/uploads/photos/resized/640x320_crop_car.png
      File.exists? File.join(@root, PhotoCook.public_dirname, uri)
    end

    def extract_uri(env)
      Rack::Utils.unescape(env['PATH_INFO'])
    end

    def default_actions(env)
      @app.call(env)
    end

    def command_regex
      @r_command ||= %r{
        \A (?<width>\d+) x (?<height>\d+) _ (?<crop>crop_)?
      }x
    end

  end
end