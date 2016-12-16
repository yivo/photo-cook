# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  class Engine < ::Rails::Engine
    initializer :photo_cook_root do |app|
      PhotoCook.root_path = Rails.root.to_s
    end

    initializer :photo_cook_logger do |app|
      PhotoCook.logger = Rails.logger
    end

    initializer :photo_cook_assets do |app|
      app.config.assets.paths << File.join(PhotoCook::Engine.root, 'app/assets/javascripts')
    end

    config.before_initialize do |app|
      app.config.middleware.insert_before(Rack::Sendfile, PhotoCook::Resize::Middleware)
    end
  end
end
