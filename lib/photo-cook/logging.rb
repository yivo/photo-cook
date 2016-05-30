module PhotoCook
  class Logger
  protected
    def decorate(msg)
      lines = msg.lines
      lines.map!(&:trim)
      "[PhotoCook] #{lines.shift}\n#{lines.map { |el| "  #{el}" }.join("\n")}"
    end
  end
  
  class STDOutLogger < Logger
    def write(msg)
      $stdout.puts(decorate(msg))
    end
  end
  
  class RailsLogger < Logger
    def write(msg)
      Rails.logger.info(decorate(msg))
    end
  end
  
  class << self
    def logger
      @logger ||= begin
        defined?(Rails) ? RailsLogger.new : STDOutLogger.new
      end
    end
  end
  
  subscribe :matched_resize_uri do |uri|
    logger.write %{ Matched resize URI.
                    URI:           #{uri} }
  end

  subscribe :will_perform_resize do
    logger.write %{ Will perform resize. }
  end

  subscribe :resize_performed do |photo, w, h, mode, msec|
    logger.write %{ Resize performed.
                    Source file:   #{photo.source_path}
                    Resized file:  #{photo.resized_path}
                    Width:         #{w == 0 ? 'auto': "#{w}px"}
                    Height:        #{h == 0 ? 'auto': "#{h}px"}
                    Mode:          #{mode}
                    Completed in:  #{msec.round(1)}ms }
  end

  subscribe :resize_not_performed do |source_path, store_path, width, height, mode|
    logger.write %{ Resize not performed. }
  end

  subscribe :will_symlink_cache_dir do |cmd|
    logger.write %{ Will symlink cache directory.
                   Command:       #{cmd} }
  end

  subscribe :symlink_cache_dir_success do
    logger.write %{ Successfully symlink cache directory. }
  end

  subscribe :symlink_cache_dir_failure do
    logger.write %{ Failed to symlink cache directory. }
  end

  subscribe :will_perform_optimization do |path|
    logger.write %{ Will perform optimization.
                   File path:     #{path}}
  end

  subscribe :optimization_performed do |path, original_size, new_size, msec|
    diff = original_size - new_size
    logger.write %{ Optimization performed.
                   File path:     #{path}
                   Original size: #{format_size(original_size)}
                   New size:      #{format_size(new_size)}
                   Saved:         #{format_size(diff)} / #{diff} bytes / #{(diff / original_size.to_f * 100.0).round(2)}%
                   Completed in:  #{msec.round(1)}ms }
  end

  subscribe :optimization_not_performed do |path|
    logger.write %{ Optimization not performed because one of the following:
                   1) photo is already optimized;
                   2) some problem occured with optimization engine.
                   File path:     #{path} }
  end
end
