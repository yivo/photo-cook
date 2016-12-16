# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  class << self
    def notify(event, *params)
      blocks = @events && @events[event.to_s]
      blocks && blocks.each { |blk| Utils.call_block_with_floating_arguments(blk, params) }
      nil
    end

    def subscribe(event, &block)
      ((@events ||= {})[event.to_s] ||= []) << block
      nil
    end
  end
end
