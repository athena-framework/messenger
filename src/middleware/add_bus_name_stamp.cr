struct Athena::Messenger::Middleware::AddBusNameStamp
  include Athena::Messenger::Middleware::Interface

  def initialize(
    @bus_name : String
  ); end

  def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
    if envelope.last?(AMG::Stamp::BusName).nil?
      envelope = envelope.with AMG::Stamp::BusName.new @bus_name
    end

    stack.next.handle envelope, stack
  end
end
