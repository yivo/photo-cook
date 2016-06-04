module PhotoCook
  class << self
    instance_eval do
      @logger = if defined?(Rails)
        Rails.logger
      else
        require 'logger'
        Logger.new(STDOUT)
      end
    end

    def log(msg)
      @logger.info('PhotoCook') { msg }
    end
  end
end
