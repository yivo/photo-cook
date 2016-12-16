# encoding: utf-8
# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'open3'
require 'base64'
require 'pathname'
require 'logger'
require 'rake'
require 'mini_magick'
require 'os'

module PhotoCook
  class << self
    attr_accessor :root_path, :public_dir
  end
  self.public_dir = 'public'
end

require 'photo-cook/utils'
require 'photo-cook/logger'
require 'photo-cook/events'
require 'photo-cook/pixels'
require 'photo-cook/device-pixel-ratio'
require 'photo-cook/device-pixel-ratio-spy'   if defined?(Rails)

require 'photo-cook/resize/__api__'
require 'photo-cook/resize/assemble'
require 'photo-cook/resize/calculations'
require 'photo-cook/resize/carrierwave'
require 'photo-cook/resize/command'
require 'photo-cook/resize/magick-photo'
require 'photo-cook/resize/middleware'
require 'photo-cook/resize/mode'
require 'photo-cook/resize/resizer'
require 'photo-cook/resize/logging'

require 'photo-cook/optimization/__api__'
require 'photo-cook/optimization/job'         if defined?(ActiveJob)
require 'photo-cook/optimization/carrierwave'
require 'photo-cook/optimization/logging'

require 'photo-cook/engine'                   if defined?(Rails)
