module PhotoCook
  module Options
    def parse_and_check_options(options)
      crop  = options.kind_of?(Hash) ? !!options[:crop] : !!options
      ratio = options.kind_of?(Hash) ? options[:pixel_ratio].to_f : 0.0
      ratio = PhotoCook.current_client_pixel_ratio.to_f unless valid_pixel_ratio?(ratio)
      [crop, valid_pixel_ratio?(ratio) ? ratio : 1.0]
    end

    def valid_pixel_ratio?(ratio)
      ratio > 0.0 && ratio < 4.0
    end
  end
  extend Options
end