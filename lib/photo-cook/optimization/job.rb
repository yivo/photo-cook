# frozen_string_literal: true
module PhotoCook
  module Optimization
    class Job < ActiveJob::Base
      queue_as :photo_cook

      def perform(path)
        PhotoCook::Optimization.perform(path)
      end
    end
  end
end
