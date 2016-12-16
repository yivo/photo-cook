# encoding: utf-8
# frozen_string_literal: true

module PhotoCookHelper
  def device_pixel_ratio
    PhotoCook.device_pixel_ratio
  end

  def resize_multiplier
    PhotoCook::Resize.multiplier
  end

  def photo_cook_cache_key
    "resize_multiplier:#{resize_multiplier}"
  end
end
