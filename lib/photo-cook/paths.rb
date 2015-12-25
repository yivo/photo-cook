module PhotoCook
  class << self
    attr_accessor :public_dir, :cache_dir, :root

    def resize_uri_indicator
      File::SEPARATOR + cache_dir
    end
  end

  self.public_dir = 'public'
  self.cache_dir  = 'resized'
  self.root       = Rails.root if rails_env?
end