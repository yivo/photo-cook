module PhotoCook

  mattr_writer :public_dir
  mattr_writer :resize_dir

  def self.public_dir
    @public_dir || 'public'
  end

  def self.resize_dir
    @resize_dir || 'resized'
  end

  def self.resize(*args)
    assemble_path(*args)
  end

  def self.assemble_path(path, width, height, crop = false)
    File.join PhotoCook.assemble_dir(path), PhotoCook.assemble_name(path, width, height, crop)
  end

  def self.assemble_dir(path)
    File.join File.dirname(path), PhotoCook.resize_dir
  end

  def self.assemble_name(path, width, height, crop = false)
    PhotoCook.assemble_prefix(width, height, crop) + File.basename(path)
  end

  def self.assemble_prefix(width, height, crop = false)
    prefix = "#{width == 0 ? '' : width}x#{height == 0 ? '' : height}"
    prefix + (crop ? 'crop_' : '_')
  end

end

require 'photo-cook/engine' if defined?(Rails)
require 'photo-cook/resizer'
require 'photo-cook/middleware'
require 'photo-cook/carrierwave'
require 'photo-cook/magick-photo'
