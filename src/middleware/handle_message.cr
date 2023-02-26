class Athena::Messenger::Middleware::HandleMessage
  include Athena::Messenger::Middleware::Interface

  def initialize(
    @locator : AMG::Handler::LocatorInterface,
    @allow_no_handlers : Bool = false
  ); end

  def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
    message = envelope.message

    h = nil

    exceptions = [] of Exception
    already_handled = false

    @locator.handlers envelope do |handler|
      if self.message_has_already_been_handled? envelope, handler
        already_handled = true
        next
      end

      begin
        h = handler

        # TODO: Check for batch handler and AckStamp
        handled_stamp = if false
                          raise ""
                        else
                          # TODO: Pass context arg for extra data
                          self.call_handler handler, message, nil, envelope.last?(AMG::Stamp::HandlerContext)
                        end

        envelope = envelope.with handled_stamp
        Log.info { "Message '#{message.class}' handled by '#{handler.name}'" }
      rescue ex : Exception
        exceptions << ex
      end
    end

    # TODO: Check for FlushBatchHandlersStamp

    if h.nil? && !already_handled
      unless @allow_no_handlers
        # TODO: Raise NoHandlerForMessageException
      end

      Log.info { "No handler for message '#{message.class}'" }
    end

    unless exceptions.empty?
      raise "exception yo"
      # TODO: Raise HandlerFailedException
    end

    stack.next.handle envelope, stack
  end

  private def message_has_already_been_handled?(envelope : AMG::Envelope, handler : AMG::Handler::Descriptor) : Bool
    envelope.all(AMG::Stamp::Handled) do |stamp|
      return true if handler.name == stamp.handler_name
    end

    false
  end

  private def call_handler(
    handler : AMG::Handler::Descriptor,
    message : AMG::Message,
    acknowledger : AMG::Handler::Acknowledger?,
    handler_context : AMG::Stamp::HandlerContext?
  ) : AMG::Stamp::Handled
    handler.call message, acknowledger, handler_context.try &.context
  end
end
