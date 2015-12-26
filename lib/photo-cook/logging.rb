module PhotoCook
  module Logging
    def log_resize(photo, w, h, px_ratio, crop, msec)
      msg = %{
        [PhotoCook] Resized photo.
        Source file:  #{photo.source_path}
        Resized file: #{photo.resized_path}
        Width:        #{w == 0 ? 'auto': "#{w}px"}
        Height:       #{h == 0 ? 'auto': "#{h}px"}
        Crop:         #{crop ? 'yes' : 'no'}
        Pixel ratio:  #{px_ratio}
        Completed in: #{msec.round(1)}ms
      }
      rails_env? ? Rails.logger.info(msg) : print(msg)
    end
  end
  extend Logging
end