module PhotoCook
  class << self
    attr_accessor :public_dir, :cache_dir
  end

  self.public_dir = 'public'
  self.cache_dir  = 'photo-cook-cache'
end