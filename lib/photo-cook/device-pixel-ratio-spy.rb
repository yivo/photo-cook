# frozen_string_literal: true
module PhotoCook
  module DevicePixelRatioSpy
    extend ActiveSupport::Concern

    included { before_action :pass_device_pixel_ratio }

    def pass_device_pixel_ratio
      ratio = PhotoCook::DevicePixelRatio.parse(cookies[:DevicePixelRatio])
      PhotoCook.device_pixel_ratio = if PhotoCook::DevicePixelRatio.valid?(ratio)
        ratio
      else
        PhotoCook::DevicePixelRatio::DEFAULT
      end
    end
  end
end
