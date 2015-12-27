module PhotoCook
  class Engine < ::Rails::Engine
    initializer :photo_cook_javascripts do |app|
      app.config.assets.paths << File.join(PhotoCook::Engine.root, 'app/assets/javascripts')
    end
  end
end