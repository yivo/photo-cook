module PhotoCook
  class << self
    attr_accessor :public_dir, :cache_dir
    attr_writer :root
  end

  self.public_dir = 'public'
  self.cache_dir  = 'resize-cache'

  def self.root
    @root ||= (rails_env? ? Rails.root : nil)
  end
end