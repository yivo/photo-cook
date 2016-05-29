module PhotoCook
  module Events
    def notify(event, *params)
      blocks = @events && @events[event]
      blocks && blocks.each { |blk| call_block_with_floating_arguments(blk, params) }
      nil
    end

    def subscribe(event, &block)
      ((@events ||= {})[event] ||= []) << block
      nil
    end

  private
    def call_block_with_floating_arguments(callable, args)
      arity         = callable.arity
      resized_args  = arity < 0 ? args : args[0...arity]
      callable.call(*resized_args)
    end
  end

  extend Events
end
