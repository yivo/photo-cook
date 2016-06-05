# frozen_string_literal: true
module PhotoCook
  module Resize
    class Middleware

      def initialize(app)
        @app = app
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
          Assemble.resize_uri?(uri) == false ||

          # If for some reasons file exists but request went to Ruby app
          requested_file_exists?(uri)

        # At this point we are sure that this request is targeting to resize photo
        PhotoCook.notify('resize:middleware:match', uri)

        # Matched data: width=auto&height=640&mode=fill
        command = Command.extract(uri)

        # Assemble path of the source photo:
        #   => /application/public/uploads/photos/1/car.png
        source_path = Assemble.assemble_source_path_from_resize_uri(root_path, uri)

        # Assemble path of the resized photo:
        #   => /application/public/resized/uploads/photos/1/COMMAND/car.png
        store_path = Assemble.assemble_store_path(root_path, source_path, command.to_s)

        if File.readable?(store_path)
          symlink_cache_dir(source_path, store_path)
          default_actions(env)

        elsif File.readable?(source_path)
          # Finally resize photo
          # Resized photo will appear in resize directory
          Resize.perform(source_path, store_path, command[:width], command[:height], command[:mode])
          symlink_cache_dir(source_path, store_path)
          respond_with_file(env)

        else
          default_actions(env)
        end
      end

    protected
      def root_path
        PhotoCook.root_path
      end

      def public_path
        PhotoCook::Resize::Assemble.assemble_public_path(root_path)
      end

      def requested_file_exists?(uri)
        # Check if file exists:
        #   /application/public/uploads/photos/1/resized/width=auto&height=640&mode=fill/car.png
        File.readable?(File.join(public_path, uri))
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
        status, headers, body = Rack::File.new(public_path).call(env)
        response = Rack::Response.new(body, status, headers)
        response.finish
      end

      def symlink_cache_dir(source_path, store_path)
        PhotoCook::Utils.make_relative_symlink(
            File.dirname(File.dirname(store_path)),
            File.join(File.dirname(source_path), PhotoCook::Resize.cache_dir))
      end
    end
  end
end
