module PhotoCook
  module Optimization
    class << self
      def optimizer
        ImageOptim.instance
      end

      def perform(path)
        if File.readable?(path) && (optimizer = self.optimizer)
          PhotoCook.notify(:will_perform_optimization, path)
          result, msec = PhotoCook::Utils.measure { optimizer.optimize(path) }
          params       = [path]
          params.push(result[:before], result[:after], msec) if result
          PhotoCook.notify(:"optimization_#{'not_' unless result}performed", *params)
          !!result
        else
          false
        end
      end
    end
  end
end
