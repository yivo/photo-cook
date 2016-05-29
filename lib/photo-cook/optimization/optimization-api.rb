module PhotoCook
  class << self
    def optimizer
      ImageOptim.instance
    end

    def perform_optimization(path)
      if File.exists?(path) && (optimizer = self.optimizer)
        notify(:will_perform_optimization, path)
        result, msec = measure { optimizer.optimize(path) }
        params       = [path]
        params.push(result[:before], result[:after], msec) if result
        notify(:"optimization_#{'not_' unless result}performed", *params)
        !!result
      else
        false
      end
    end
  end
end
