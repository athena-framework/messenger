struct Athena::Messenger::Middleware::DispatchAfterCurrentBus
  include Athena::Messenger::Middleware::Interface

  private struct QueuedEnvelope
    getter envelope : AMG::Envelope
    getter stack : AMG::Middleware::StackInterface

    def initialize(
      envelope : AMG::Envelope,
      @stack : AMG::Middleware::StackInterface
    )
      @envelope = envelope.without AMG::Stamp::DispatchAfterCurrentBus
    end
  end

  @queue = Array(QueuedEnvelope).new
  @root_dispatcher_call_running = false

  def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
    unless envelope.last?(AMG::Stamp::DispatchAfterCurrentBus).nil?
      if @root_dispatcher_call_running
        @queue << QueuedEnvelope.new envelope, stack
      end

      envelope = envelope.without AMG::Stamp::DispatchAfterCurrentBus
    end

    if @root_dispatcher_call_running
      # A call to MessageBusInterface#dispatch was made from inside the main bus handling the message,
      # but the message does not have the stamp. So, process it like normal.
      return stack.next.handle envelope, stack
    end

    # Mark inside "root dispatcher" call
    @root_dispatcher_call_running = true

    begin
      returned_envelope = stack.next.handle envelope, stack
    rescue e : Exception
      # Drop the queued messages upon an exception since the queued commands were likely dependent on the preceding command.
      @queue.clear
      @root_dispatcher_call_running = false

      raise e
    end

    exceptions = [] of Exception

    until (queue_item = @queue.shift?).nil?
      # How many messages are left in queue before processing
      queue_length_before = @queue.size

      begin
        queue_item.stack.next.handle queue_item.envelope, queue_item.stack
      rescue ex : Exception
        exceptions << ex
        # Restore queue to previous state
        @queue = @queue.first queue_length_before
      end
    end

    @root_dispatcher_call_running = false

    unless exceptions.empty?
      raise AMG::Exceptions::DelayedMessageHandling.new exceptions
    end

    returned_envelope
  end
end
