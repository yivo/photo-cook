require File.expand_path('../lib/photo_cook/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'photo_cook'
  s.version     = PhotoCook::VERSION
  s.authors     = ['Yaroslav Konoplov']
  s.email       = ['the.yivo@gmail.com']
  s.homepage    = 'https://github.com/yivo/photo_cook'
  s.summary     = 'Simple solution for photo resizing.'
  s.description = 'This is a simple solution for photo resizing.'
  s.license     = 'MIT'
  s.files       = Dir['{lib}/**/*']

  s.add_dependency 'rack', '~> 1.5'
  s.add_dependency 'mini_magick', '~> 4.0'
end