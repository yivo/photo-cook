# frozen_string_literal: true
module PhotoCook
  module Resize
    class MagickPhoto < MiniMagick::Image
      attr_accessor :source_path
      attr_accessor :store_path

      attr_accessor :desired_width
      attr_accessor :desired_height

      attr_accessor :calculated_width
      attr_accessor :calculated_height

      attr_accessor :resize_mode

      attr_reader :max_width
      attr_reader :max_height

      def initialize(*)
        super
        @max_width  = self[:width]
        @max_height = self[:height]
      end

      def desired_aspect_ratio
        desired_width / desired_height.to_f
      end

      def calculated_aspect_ratio
        calculated_width / calculated_height.to_f
      end
    end
  end
end
