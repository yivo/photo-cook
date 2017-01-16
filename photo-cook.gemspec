# encoding: utf-8
# frozen_string_literal: true

require File.expand_path('../lib/photo-cook/version', __FILE__)

Gem::Specification.new do |s|
  s.name            = 'photo-cook'
  s.version         = PhotoCook::VERSION
  s.authors         = ['Yaroslav Konoplov']
  s.email           = ['eahome00@gmail.com']
  s.homepage        = 'http://github.com/yivo/photo-cook'

  # TODO Write better summary and description
  s.summary         = 'Tool for resizing and optimizing photos in Ruby'
  s.description     = 'This gem provides complete tool for resizing and optimizing photos in Ruby'
  s.license         = 'MIT'

  s.executables     = `git ls-files -z -- bin/*`.split("\x0").map { |f| File.basename(f) }
  s.files           = `git ls-files -z`.split("\x0")
  s.test_files      = `git ls-files -z -- {test,spec,features}/*`.split("\x0")
  s.require_paths   = %w( app lib )

  s.add_dependency 'rack',        '~> 1.5'
  s.add_dependency 'mini_magick', '~> 4.0'

  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake',    '~> 10.0'
end
