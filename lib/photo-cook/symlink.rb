module PhotoCook
  module Symlink
    def symlink_cache_dir(source_path, store_path)
      # /application/public/uploads/photos/1
      p1 = Pathname.new(File.dirname(source_path))

      # /application/public/resized/uploads/photos/1
      p2 = Pathname.new(File.dirname(File.dirname(store_path)))

      # ../../../resized/uploads/photos/1
      relative = p2.relative_path_from(p1)

      # Guess cache directory (must be same as PhotoCook.cache_dir)
      cache_dir = relative.to_s.split(File::SEPARATOR).find { |el| !(el =~ /\A\.\.?\z/) }

      unless Dir.exists?(p1.join(cache_dir))
        flags = PhotoCook.ln_explicitly_needs_relative_flag? ? '-rs' : '-s'
        cmd   = "cd #{p1} && rm -rf #{cache_dir} && ln #{flags} #{relative} #{cache_dir}"
        PhotoCook.notify(:will_symlink_cache_dir, cmd)
        %x{ #{cmd} }
        PhotoCook.notify(:"symlink_cache_dir_#{$?.success? ? 'success' : 'failure'}")
      end
    end

  private
    def ln_explicitly_needs_relative_flag?
      if @relative_flag_illegal.nil?
        out = Open3.capture2e('ln', '-rs')[0]
        @relative_flag_illegal = !!(out =~ /\billegal\b/)
      end
      @relative_flag_illegal == false
    end
  end

  extend Symlink
end
