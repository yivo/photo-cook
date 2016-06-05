# frozen_string_literal: true
module PhotoCook
  module Resize
    module CarrierWave
      def resize(w, h, mode = :fit, options = {})
        PhotoCook::Resize.uri(url, w, h, mode, options)
      end

      def resize_to_fit(w, h, options = {})
        PhotoCook::Resize.uri(url, w, h, :fit, options)
      end

      def resize_to_fill(w, h, options = {})
        PhotoCook::Resize.uri(url, w, h, :fill, options)
      end

      def resize_inline(w, h, mode = :fit, options = {})
        PhotoCook::Resize.base64_uri(url, w, h, mode, options)
      end
    end
  end
end
