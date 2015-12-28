module PhotoCook
  module API
    module Optimization
      def optimizer
        ImageOptim.instance
      end

      def perform_optimization(path, options = {})
        if File.exists?(path) && (optimizer = self.optimizer)
          optimizer.optimize(path, options)
          true
        else
          false
        end
      end
    end
  end

  extend API::Optimization
end