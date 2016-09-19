# frozen_string_literal: true
module PhotoCook
  module Resize
    module Assemble
      class << self
        # Returns URI which points to PhotoCook::Resize::Middleware
        #
        # Arguments:
        #   source_uri  => /uploads/photos/1/car.png
        #   width       => :auto
        #   height      => 640
        #   mode        => fit
        #
        # Returns /uploads/photos/1/resized/width=auto&height=640&mode=fit/car.png
        #
        # NOTE: This method performs no validation
        # NOTE: This method is very hot
        def assemble_resize_uri(source_uri, width, height, mode)
          source_uri.split('/').insert(-2, PhotoCook::Resize.cache_dir, Command.assemble(width, height, mode)).join('/')
        end

        # Strips resize command from URI. Inverse of +assemble_resize_uri+
        #
        # Arguments:
        #   resize_uri => /uploads/photos/1/resized/width=auto&height=640&mode=fit/car.png
        #
        # Returns /uploads/photos/1/car.png
        #
        # NOTE: This method performs no validation
        def disassemble_resize_uri(resize_uri)
          # Take URI:
          # /uploads/photos/1/resized/width=auto&height=640&mode=fit/car.png
          #
          # Split by separator:
          # ["", "uploads", "photos", "1", "resized", "width=auto&height=640&mode=fit", "car.png"]
          #
          sections = resize_uri.split('/')

          # Delete PhotoCook directory:
          # ["", "uploads", "photos", "1", "width=auto&height=640&mode=fit", "car.png"]
          sections.delete_at(-3)

          # Delete command string:
          # ["", "uploads", "photos", "1", "car.png"]
          sections.delete_at(-2)

          sections.join('/')
        end

        # Path where source photo is stored
        #
        # Arguments:
        #   root       => /application
        #   resize_uri => /uploads/photos/1/resized/width=auto&height=640&mode=fit/car.png
        #
        # Returns /application/public/uploads/photos/1/car.png
        #
        # NOTE: This method performs no validation
        def assemble_source_path_from_resize_uri(root, resize_uri)
          assemble_source_path_from_normal_uri(root, disassemble_resize_uri(resize_uri))
        end

        def assemble_source_path_from_normal_uri(root, normal_uri)
          File.join(assemble_public_path(root), normal_uri)
        end

        # Path where resized photo is stored
        #
        # Arguments:
        #   root              => /application
        #   source_path       => /application/public/uploads/photos/1/car.png
        #   assembled_command => width=auto&height=640&mode=fit
        #
        # Returns /application/public/resized/uploads/photos/1/width=auto&height=640&mode=fit/car.png
        #
        # NOTE: This method performs no validation
        def assemble_store_path(root, source_path, assembled_command)
          public         = assemble_public_path(root)
          photo_location = dirname_or_blank(source_path.split(public).last)
          File.join(public, PhotoCook::Resize.cache_dir, photo_location, assembled_command, File.basename(source_path))
        end

        # Path to public directory
        #
        # Arguments:
        #   root => /application
        #
        # Returns /application/public
        #
        # NOTE: This method performs no validation
        def assemble_public_path(root)
          File.join(root, PhotoCook.public_dir)
        end

        def resize_uri?(uri)
          sections = uri.split('/')

          # Check if PhotoCook cache directory exists:
          #   sections[-3] => resized
          sections[-3] == PhotoCook::Resize.cache_dir &&

          # Check if valid resize command exists:
          #   sections[-2] => width=auto&height=640&mode=fit
          matches_regex?(sections[-2], Command.regex)
        end

      private
        def dirname_or_blank(path)
          File.dirname(path).sub(/\A\.\z/, '')
        end

        # Ruby 2.4 Regexp#match?
        if Regexp.instance_methods.include?(:match?)
          def matches_regex?(string, regex)
            regex.match?(string)
          end
        else
          def matches_regex?(string, regex)
            regex === string
          end
        end
      end
    end
  end
end
