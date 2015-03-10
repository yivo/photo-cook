module PhotoCook

  mattr_writer :public_dir_name
  mattr_writer :resize_dir_name

  def self.public_dir_name
    @public_dir_name || 'public'
  end

  def self.resize_dir_name
    @resize_dir_name || 'resized'
  end

  def self.assemble_prefix(width, height, crop = false)
    prefix = "#{width}x#{height}_"
    prefix += 'crop_' if crop
    prefix
  end

end

require 'photo_cook/engine' if defined?(Rails)
require 'photo_cook/resizer'
require 'photo_cook/middleware'
require 'photo_cook/carrierwave'
