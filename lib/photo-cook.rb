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
    File.basename(path, '.*') + PhotoCook.assemble_command(width, height, crop) + File.extname(path)
  end

  def self.assemble_command(width, height, crop = false)
    prefix = "_#{width == 0 ? '' : width}x#{height == 0 ? '' : height}"
    prefix + (crop ? 'crop' : '')
  end

end

require 'photo-cook/engine' if defined?(Rails)
require 'photo-cook/resizer'
require 'photo-cook/middleware'
require 'photo-cook/carrierwave'
require 'photo-cook/magick-photo'
