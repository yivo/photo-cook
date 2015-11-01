module PhotoCook
  def self.rails?
    defined?(::Rails)
  end
end

if PhotoCook.rails?
  require 'photo-cook/engine'
  require 'photo-cook/cookie-pixel-ratio'
end

require 'photo-cook/carrierwave'
require 'photo-cook/dimensions'
require 'photo-cook/assemble'
require 'photo-cook/options'
require 'photo-cook/callbacks'
require 'photo-cook/command-regex'
require 'photo-cook/logging'
require 'photo-cook/resizer'
require 'photo-cook/middleware'
require 'photo-cook/magick-photo'