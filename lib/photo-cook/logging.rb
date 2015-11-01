module PhotoCook
  module Logging
    def log_resize(photo, command)
      w     = command[:width].to_i
      h     = command[:height].to_i
      crop  = !!command[:crop]
      msg = %{
        [PhotoCook] Resized photo.
        Source file:  "#{photo.source_path}"
        Resized file: "#{photo.resized_path}"
        Width:        #{w == 0 ? 'auto': "#{w}px"}
        Height:       #{h == 0 ? 'auto': "#{h}px"}
        Crop:         #{crop ? 'yes' : 'no'}
      }
      rails? ? ::Rails.logger.info(msg) : print(msg)
    end
  end
  extend Logging
end