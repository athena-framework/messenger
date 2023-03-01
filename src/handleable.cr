module Athena::Messenger::Handleable(T)
  @message_bus : AMG::MessageBusInterface

  def handle(message : AMG::Message | AMG::Envelope) : T
    envelope = @message_bus.dispatch message

    handled_stamps = envelope.all AMG::Stamp::Handled

    if handled_stamps.empty?
      raise AMG::Exceptions::Logic.new "Message of type '#{envelope.message.class}' was handled zero times. Exactly one handler is expected when using '#{self.class}##{{{@def.name.stringify}}}'."
    end

    if handled_stamps.size > 1
      handlers = handled_stamps.join ", " { |s| "'#{s.handler_name}'" }

      raise AMG::Exceptions::Logic.new "Message of type '#{envelope.message.class}' was handled multiple times. Exactly one handler is expected when using '#{self.class}##{{{@def.name.stringify}}}', got #{handled_stamps.size}: #{handlers}."
    end

    handled_stamps.first.result.as T
  end
end
