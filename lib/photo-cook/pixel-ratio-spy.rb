module PhotoCook
  module PixelRatioSpy
    extend ActiveSupport::Concern

    included do
      before_action :pass_pixel_ratio
    end

    def pass_pixel_ratio
      ratio = cookies[:PhotoCookPixelRatio].to_f
      # Dont set pixel ratio if for some reasons it is invalid
      PhotoCook.client_pixel_ratio = PhotoCook.valid_pixel_ratio?(ratio) ? ratio : nil
    end
  end

  class << self
    attr_accessor :client_pixel_ratio
  end
end