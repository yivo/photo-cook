module PhotoCook
  class << self
    def measure
      started  = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
      returned = yield
      finished = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
      [returned, finished - started]
    end
  end
end
