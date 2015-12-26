require 'fileutils'
require 'rake'
require 'mini_magick'

module PhotoCook
  def self.rails_env?
    defined?(Rails)
  end
end

require 'photo-cook/dimensions'
require 'photo-cook/pixel-ratio'
require 'photo-cook/paths'
require 'photo-cook/command'
require 'photo-cook/assemble'
require 'photo-cook/callbacks'
require 'photo-cook/logging'
require 'photo-cook/resizer'
require 'photo-cook/middleware'
require 'photo-cook/magick-photo'
require 'photo-cook/carrierwave'
require 'photo-cook/resizing'

if PhotoCook.rails_env?
  require 'photo-cook/engine'
  require 'photo-cook/pixel-ratio-spy'
end