# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  module Optimization
    module CarrierWave
      def optimize
        PhotoCook::Optimization.perform(current_path)
      end
    end
  end
end
