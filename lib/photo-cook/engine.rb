module PhotoCook
  class Engine < ::Rails::Engine
    initializer :photo_cook_root do |app|
      PhotoCook.root = Rails.root
    end

    initializer :photo_cook_javascripts do |app|
      app.config.assets.paths << File.join(PhotoCook::Engine.root, 'app/assets/javascripts')
    end

    config.before_initialize do |app|
      app.config.middleware.insert_before(Rack::Sendfile, PhotoCook::Middleware, Rails.root)
    end
  end
end
