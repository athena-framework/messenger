# Message
# Message + Context
# Message + Ack
# Message + Ack + Context

# :nodoc:
abstract struct Athena::Messenger::Handler::Descriptor
  getter name : String
  getter batch_handler : AMG::Handler::BatchHandlerInterface?
  getter from_transport : String?

  private def initialize(
    name : String?,
    @from_transport : String?,
    @batch_handler : AMG::Handler::BatchHandlerInterface?
  )
    @name = name || "unknown handler"
  end

  struct Message(M, R) < Athena::Messenger::Handler::Descriptor
    @handler : M -> R

    def initialize(
      @handler : M -> R,
      name : String?,
      from_transport : String? = nil,
      batch_handler : AMG::Handler::BatchHandlerInterface? = nil
    )
      super name, from_transport, nil
    end

    def call(message : AMG::Message, acknowledger : AMG::Handler::Acknowledger?, context : AMG::Handler::Context? = nil) : AMG::Stamp::Handled
      AMG::Stamp::Handled.new @handler.call(message.as M), @name
    end
  end

  struct MessageContext(M, C, R) < Athena::Messenger::Handler::Descriptor
    @handler : M, C? -> R

    def initialize(
      @handler : M, C? -> R,
      name : String?,
      from_transport : String? = nil
    )
      super name, from_transport, nil
    end

    def call(message : AMG::Message, acknowledger : AMG::Handler::Acknowledger?, context : AMG::Handler::Context? = nil) : AMG::Stamp::Handled
      AMG::Stamp::Handled.new @handler.call(message.as M, context.as C?), @name
    end
  end

  # struct MessageAck(M, R) < Athena::Messenger::Handler::Descriptor
  #   @handler : M, AMG::Handler::Acknowledger -> R

  #   def initialize(
  #     @handler : M, AMG::Handler::Acknowledger -> R,
  #     name : String?,
  #     from_transport : String? = nil,
  #     batch_handler : AMG::Handler::BatchHandlerInterface? = nil
  #   )
  #     super name, from_transport, (@handler.is_a?(AMG::Handler::BatchHandlerInterface) ? @handler : nil)
  #   end

  #   def call(message : M) : R
  #     @handler.call message
  #   end
  # end

  # struct MessageAckContext(M, C, R) < Athena::Messenger::Handler::Descriptor
  #   @handler : M, AMG::Handler::Acknowledger, C -> R

  #   def initialize(
  #     @handler : M, AMG::Handler::Acknowledger, C -> R,
  #     name : String?,
  #     from_transport : String? = nil,
  #     batch_handler : AMG::Handler::BatchHandlerInterface? = nil
  #   )
  #     super name, from_transport, (batch_handler.is_a?(AMG::Handler::BatchHandlerInterface) ? @handler : nil)
  #   end

  #   def call(message : M, acknowledger : AMG::Handler::Acknowledger) : R
  #     @handler.call message, acknowledger
  #   end
  # end
end
