# To use this middleware you should configure application:
# application.config.middleware.insert_before(Rack::Sendfile, PhotoCook::Middleware, Rails.root)
module PhotoCook
  class Middleware

    def initialize(app, root)
      @app, @root = app, root
    end

    # The example will be concentrated around uri:
    # /uploads/photos/resized/640x320_crop_car.png
    def call(env)
      @env = env

      return default if requested_file_exists?

      return default unless

        # Lets ensure that directory name matches PhotoCook.resize_dirname
        # dirname = /uploads/photos/resized
        # File::SEPARATOR + PhotoCook.resize_dirname = /resized
        # dirname.chomp! = /uploads/photos
        (dirname = File.dirname(uri)).chomp!(File::SEPARATOR + PhotoCook.resize_dirname) &&

        # Lets ensure that photo_name starts with resize command
        # photo_name = 640x320_crop_car.png
        # photo_name.sub! = car.png
        (photo_name = File.basename(uri)).sub!(command_regex, '')

      # Regex match: 640x320_crop_
      command = Regexp.last_match

      # At this point we are sure that this request is targeting to resize photo

      # Lets assemble path of the source photo
      source = assemble_source_photo_path dirname, photo_name

      # Do nothing if source photo not exists
      return default unless File.exists?(source)

      # Finally resize photo
      resizer = PhotoCook::Resizer.instance

      # Resizer will store photo in resize directory
      resizer.resize source, command[:width].to_i, command[:height].to_i, !!command[:crop]

      # Return control to Rack::Sendfile which will find resized photo and send it to client!
      default
    end

    private

    attr_reader :app, :root, :env

    def assemble_source_photo_path(dirname, photo_name)
      URI.decode File.join(root, PhotoCook.public_dirname, dirname, photo_name)
    end

    def requested_file_exists?
      # /my_awesome_project_root/public/uploads/photos/resized/640x320_crop_car.png
      File.exists? File.join(root, PhotoCook.public_dirname, uri)
    end

    def uri
      env['PATH_INFO']
    end

    def default
      @app.call env
    end

    def command_regex
      @r_command ||= %r{
        \A (?<width>\d+) x (?<height>\d+) _ (?<crop>crop_)?
      }x
    end

  end
end