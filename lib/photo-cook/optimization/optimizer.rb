module PhotoCook
  module Optimization
    class Optimizer
      include Singleton

      def optimize(path)
        raise NotImplementedError
      end
    end
  end
end
