module PhotoCook
  module PixelRatioSpy
    extend ActiveSupport::Concern

    included do
      before_action :pass_cookie_pixel_ratio_to_photo_cook
    end

    def pass_cookie_pixel_ratio_to_photo_cook
      PhotoCook.current_client_pixel_ratio = cookies[:PhotoCookPixelRatio].to_f
    end
  end
  mattr_accessor :current_client_pixel_ratio
end