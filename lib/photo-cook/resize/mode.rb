# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  module Resize
    module Mode
      class << self
        def parse(mode)
          case mode
            when true          then :fill
            when false         then :fit
            when :fit, :fill   then mode
            when 'fit', 'fill' then mode.to_sym
          end
        end

        def parse!(mode)
          check!(mode = parse(mode))
          mode
        end

        def check!(mode)
          case mode
            when :fill, :fit then true
            else raise Unknown, mode
          end
          true
        end
      end

      class Unknown < ::ArgumentError
        def initialize(mode)
          super "Mode #{mode} is unknown"
        end
      end
    end
  end
end
