# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  module Optimization
    class << self
      # TODO PhotoCook::Optimization.optimizer = :image_optim
      attr_accessor :optimizer

      def perform(path)
        if File.readable?(path) && (optimizer = self.optimizer)
          result, msec = PhotoCook::Utils.measure { optimizer.optimize(path) }
          params       = [path]
          params.push(result[:before], result[:after], msec) if result
          PhotoCook.notify("optimization:#{result ? 'success' : 'failure'}", *params)
          !!result
        else
          false
        end
      end
    end
  end
end
