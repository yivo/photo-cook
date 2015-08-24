# To use this middleware you should configure application:
# application.config.middleware.insert_before(Rack::Sendfile, PhotoCook::Middleware, Rails.root)
require 'rack'

module PhotoCook
  class Middleware

    def initialize(app, root)
      @app, @root = app, root
    end

    # The example will be concentrated around uri:
    # /uploads/photos/resized/car-640x320crop.png
    def call(env)
      uri = extract_uri(env)

      return default_actions(env) unless

        # Lets ensure that directory matches PhotoCook.resize_dir
        # dir = /uploads/photos/resized
        # File::SEPARATOR + PhotoCook.resize_dir = /resized
        # dir.chomp! = /uploads/photos
        (dir = File.dirname(uri)).chomp!(File::SEPARATOR + PhotoCook.resize_dir) &&

        # Lets ensure that photo_basename ends with resize command
        # photo_name = car-640x320crop.png
        # photo_basename = car-640x320crop
        # photo_basename.sub! = car.png
        (photo_name = File.basename(uri)) &&
        (photo_basename = File.basename(photo_name, '.*')).sub!(command_regex, '')

      return default_actions(env) if requested_file_exists?(uri)

      # Regex match: _640x320crop
      command = Regexp.last_match

      # At this point we are sure that this request is targeting to resize photo

      # Lets assemble path of the source photo
      source_path = assemble_source_path(dir, photo_basename + File.extname(photo_name))

      # Finally resize photo
      resizer = PhotoCook::Resizer.instance

      # Resizer will store photo in resize directory
      photo = resizer.resize source_path, command[:width].to_i, command[:height].to_i, !!command[:crop]

      if photo
        # http://rubylogs.com/writing-rails-middleware/
        # https://viget.com/extend/refactoring-patterns-the-rails-middleware-response-handler
        status, headers, body = Rack::File.new(File.join(@root, PhotoCook.public_dir)).call(env)
        response = Rack::Response.new(body, status, headers)
        response.finish
      else
        default_actions(env)
      end
    end

    private

    def assemble_source_path(dir, photo_name)
      URI.decode File.join(@root, PhotoCook.public_dir, dir, photo_name)
    end

    def requested_file_exists?(uri)
      # /my_awesome_project_root/public/uploads/photos/resized/car-640x320crop.png
      File.exists? File.join(@root, PhotoCook.public_dir, uri)
    end

    def extract_uri(env)
      Rack::Utils.unescape(env['PATH_INFO'])
    end

    def default_actions(env)
      @app.call(env)
    end

    # Proportional support
    # http://stackoverflow.com/questions/7200909/imagemagick-convert-to-fixed-width-proportional-height
    def command_regex
      unless @r_command
        w = /(?<width>\d+)/
        h = /(?<height>\d+)/
        @r_command = %r{
          \- (?:(?:#{w}x#{h}) | (?:#{w}x) | (?:x#{h})) (?<crop>crop)? \z
        }x
      end
      @r_command
    end
  end
end