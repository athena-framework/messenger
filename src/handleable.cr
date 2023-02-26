module Athena::Messenger::Handleable(T)
  @message_bus : AMG::MessageBusInterface

  def handle(message : AMG::Message | AMG::Envelope) : T
    envelope = @message_bus.dispatch message

    handled_stamps = envelope.all AMG::Stamp::Handled

    if handled_stamps.empty?
      raise "Handled zero times"
    end

    if handled_stamps.size > 1
      raise "Handled multiple times"
    end

    handled_stamps.first.result.as T
  end
end
