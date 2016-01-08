require 'fileutils'
require 'pathname'
require 'rake'
require 'mini_magick'
require 'open3'
require 'base64'

module PhotoCook
  def self.rails_env?
    @rails.nil? ? @rails = !!defined?(Rails) : @rails
  end
end

require 'photo-cook/dimensions'
require 'photo-cook/pixel-ratio'
require 'photo-cook/dirs'
require 'photo-cook/command'
require 'photo-cook/assemble'
require 'photo-cook/logging'
require 'photo-cook/resizer'
require 'photo-cook/middleware'
require 'photo-cook/magick-photo'
require 'photo-cook/carrierwave'
require 'photo-cook/abstract-optimizer'
require 'photo-cook/image-optim'
require 'photo-cook/resize-api'
require 'photo-cook/optimization-api'
require 'photo-cook/size-formatting'

if PhotoCook.rails_env?
  require 'photo-cook/engine'
  require 'photo-cook/pixel-ratio-spy'
  require 'photo-cook/optimization-job'
end
