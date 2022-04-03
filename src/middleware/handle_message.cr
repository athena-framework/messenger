class Athena::Messenger::Middleware::HandleMessage
  include Athena::Messenger::Middleware::Interface

  def initialize(
    @locator : AMG::Handler::LocatorInterface,
    @allow_no_handlers : Bool = false
  ); end

  def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
    message = envelope.message

    # TODO: Setup log context

    exceptions = [] of Exception
    at_least_one_handler = false

    @locator.handlers envelope do |handler|
      next if self.message_has_already_been_handled? envelope, handler

      # TODO: Check for batch handler and AckStamp

      handled_stamp = handler.invoke message

      envelope << handled_stamp
      # TODO: Add logging

    rescue ex : Exception
      exceptions << ex
    else
      at_least_one_handler = true
    end

    # TODO: Check for FlushBatchHandlersStamp

    unless at_least_one_handler
      unless @allow_no_handlers
        # TODO: Raise NoHandlerForMessageException
      end

      # TODO: Add logging
    end

    unless exceptions.empty?
      # TODO: Raise HandlerFailedException
    end

    # stack.next.handle envelope, stack
    envelope
  end

  private def message_has_already_been_handled?(envelope : AMG::Envelope, handler : AMG::Handler::Type) : Bool
    envelope.all(AMG::Stamp::Handled) do |stamp|
      return true if handler.name(envelope.message) == stamp.handler_name
    end

    false
  end
end
