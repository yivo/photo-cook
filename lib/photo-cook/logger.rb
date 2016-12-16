# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  class << self
    attr_accessor :logger
    attr_accessor :logger_evaluator

    def log(&block)
      logger_evaluator.instance_eval do
        log "\n"
        log '--- PhotoCook ---'
        instance_eval(&block)
        log '---'
      end if @logging_enabled
      nil
    end

    def enable_logging!
      @logging_enabled = true
      nil
    end

    def disable_logging!
      @logging_enabled = false
      nil
    end
  end

  class LoggerEvaluator
    def log(msg)
      PhotoCook.logger.info(msg)
    end
  end

  self.logger           = Logger.new(STDOUT)
  self.logger_evaluator = LoggerEvaluator.new
  enable_logging!
end
