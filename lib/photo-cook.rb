module PhotoCook

  mattr_writer :public_dirname
  mattr_writer :resize_dirname

  def self.public_dirname
    @public_dirname || 'public'
  end

  def self.resize_dirname
    @resize_dirname || 'resized'
  end

  def self.assemble_path(path, width, height, crop = false)
    File.join PhotoCook.assemble_dir(path), PhotoCook.assemble_name(path, width, height, crop)
  end

  def self.assemble_dir(path)
    File.join File.dirname(path), PhotoCook.resize_dirname
  end

  def self.assemble_name(path, width, height, crop = false)
    PhotoCook.assemble_prefix(width, height, crop) + File.basename(path)
  end

  def self.assemble_prefix(width, height, crop = false)
    prefix = "#{width}x#{height}_"
    prefix += 'crop_' if crop
    prefix
  end

end

require 'photo-cook/engine' if defined?(Rails)
require 'photo-cook/resizer'
require 'photo-cook/middleware'
require 'photo-cook/carrierwave'
