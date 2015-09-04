require File.expand_path('../lib/photo-cook/version', __FILE__)

Gem::Specification.new do |s|
  s.name            = 'photo-cook'
  s.version         = PhotoCook::VERSION
  s.authors         = ['Yaroslav Konoplov']
  s.email           = ['yaroslav@inbox.com']
  s.homepage        = 'http://github.com/yivo/photo-cook'
  s.summary         = 'Simple solution for photo resizing'
  s.description     = 'This is a simple solution for photo resizing.'
  s.license         = 'MIT'

  s.files           = `git ls-files -z`.split("\x0")
  s.executables     = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files      = spec.files.grep(%r{^(test|spec|features)/})
  s.require_paths   = ['lib']

  s.add_dependency 'rack', '~> 1.5'
  s.add_dependency 'mini_magick', '~> 4.0'
end