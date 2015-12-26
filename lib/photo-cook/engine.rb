module PhotoCook
  class Engine < ::Rails::Engine
    config.before_initialize do
      PhotoCook.root = Rails.root
    end

    initializer :photo_cook_javascripts do |app|
      app.config.assets.paths << File.join(PhotoCook::Engine.root, 'app/assets/javascripts')
    end
  end
end