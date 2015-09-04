require File.expand_path('../lib/photo-cook/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'photo-cook'
  s.version     = PhotoCook::VERSION
  s.authors     = ['Yaroslav Konoplov']
  s.email       = ['yaroslav@inbox.com']
  s.homepage    = 'http://github.com/yivo/photo-cook'
  s.summary     = 'Simple solution for photo resizing'
  s.description = 'This is a simple solution for photo resizing.'
  s.license     = 'MIT'
  s.files       = `git ls-files`.split("\n")

  s.add_dependency 'rack', '~> 1.5'
  s.add_dependency 'mini_magick', '~> 4.0'
end