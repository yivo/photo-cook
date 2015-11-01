module PhotoCook
  module Callbacks
    def on_resize(photo, command)
      log_resize(photo, command) if rails?
    end
  end
  extend Callbacks
end