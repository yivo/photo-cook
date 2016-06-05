# frozen_string_literal: true
module PhotoCookHelper
  def device_pixel_ratio
    PhotoCook.device_pixel_ratio
  end

  def resize_multiplier
    PhotoCook::Resize.multiplier
  end
end
