# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  module Utils
    class << self
      def format_size(bytes, precision = 2)
        if bytes >= 1_000_000_000.0
          "#{(bytes / 1_000_000_000.0).round(precision)} GB"

        elsif bytes >= 1_000_000.0
          "#{(bytes / 1_000_000.0).round(precision)} MB"

        else
          "#{(bytes / 1_000.0).round(precision)} KB"
        end
      end

      def call_block_with_floating_arguments(callable, args)
        arity         = callable.arity
        resized_args  = arity < 0 ? args : args[0...arity]
        callable.call(*resized_args)
      end

      def make_relative_symlink(source, destination)
        unless File.readable?(destination)
          # /application/public/resize-cache/uploads/photos/1
          p1 = source.kind_of?(String)      ? Pathname.new(source) : source

          # /application/public/uploads/photos/1/resize-cache
          p2 = destination.kind_of?(String) ? Pathname.new(destination) : destination

          # ../../../resize-cache/uploads/photos/1
          relative = p1.relative_path_from(p2.dirname).to_s

          # resize-cache
          basename = p2.basename.to_s

          flags    = symlink_utility_needs_relative_flag? ? '-rs' : '-s'
          cmd      = "cd #{p2.dirname.to_s} && rm -f #{basename} && ln #{flags} #{relative} #{basename}"

          %x{ #{cmd} }

          PhotoCook.log do
            log "Symlink"
            log "Source:      #{p1.to_s}"
            log "Destination: #{p2.to_s}"
            log "Command:     #{cmd}"
            log "Status:      #{$?.success? ? 'OK' : 'FAIL'}"
          end

          return $?.success?
        end
        true
      end

      def symlink_utility_needs_relative_flag?
        if @relative_flag_illegal.nil?
          out = Open3.capture2e('ln', '-rs')[0]
          @relative_flag_illegal = !!(out =~ /\billegal\b/)
        end
        @relative_flag_illegal == false
      end

      def measure
        started  = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        returned = yield
        finished = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        [returned, finished - started]
      end
    end
  end
end
