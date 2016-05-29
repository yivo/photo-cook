module PhotoCook
  class OptimizationJob < ActiveJob::Base
    queue_as :photo_cook

    def perform(path)
      PhotoCook.perform_optimization(path)
    end
  end
end