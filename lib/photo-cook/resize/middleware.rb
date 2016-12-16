# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  module Resize
    class Middleware
      class << self
        attr_accessor :headers
      end

      self.headers = { 'Cache-Control' => 'public, max-age=31536000, no-transform' }

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

        # Check if URI contains PhotoCook resize indicators
        return default_action(env) unless Assemble.resize_uri?(uri)

        # If resized photo exists but nginx or apache didn't handle this request
        return respond_with_file(env) if requested_file_exists?(uri)

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

        if File.file?(store_path) && File.readable?(store_path)
          symlink_cache_dir(source_path, store_path)
          respond_with_file(env)

        elsif File.file?(source_path) && File.readable?(source_path)
          # Finally resize photo
          # Resized photo will appear in resize directory
          Resize.perform(source_path, store_path, command[:width], command[:height], command[:mode])
          symlink_cache_dir(source_path, store_path)
          respond_with_file(env)

        else
          default_action(env)
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
        path = File.join(public_path, uri)
        File.file?(path) && File.readable?(path)
      end

      def extract_uri(env)
        Rack::Utils.clean_path_info(Rack::Utils.unescape(env['PATH_INFO']))
      end

      def default_action(env)
        @app.call(env)
      end

      def respond_with_file(env)
        # http://rubylogs.com/writing-rails-middleware/
        # https://viget.com/extend/refactoring-patterns-the-rails-middleware-response-handler
        status, headers, body = Rack::File.new(public_path).call(env)

        # Rack::File will set Last-Modified, Content-Type and Content-Length
        # We will set Cache-Control. This is default behaviour.
        # This is configurable in PhotoCook::Resize::Middleware.headers
        headers.merge!(self.class.headers) if status == 200 || status == 304

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
