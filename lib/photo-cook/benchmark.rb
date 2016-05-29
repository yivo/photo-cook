module PhotoCook
  module Benchmark
    def measure
      started  = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      returned = yield
      finished = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      [returned, finished - started]
    end
  end

  extend Benchmark
end
