module PhotoCook
  class ImageOptim < AbstractOptimizer
    def optimize(path, options = {})
      PhotoCook.logger.will_perform_optimization(path)

      image_optim = options.empty? ? default_image_optim : ::ImageOptim.new(options)
      result = image_optim.optimize_image!(path)

      case result
        when ::ImageOptim::ImagePath::Optimized
          PhotoCook.logger.performed_optimization(path, result.original_size, result.size)
        else
          PhotoCook.logger.no_optimization_performed(path)
      end

      result
    end

  private
    def default_image_optim
      @default_image_optim ||= ::ImageOptim.new
    end
  end
end