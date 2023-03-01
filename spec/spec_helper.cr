require "spec"

require "athena-spec"
require "../src/athena-messenger"

require "./fixtures/**"

ASPEC.run_all

struct MockBus
  include AMG::MessageBusInterface

  @callback : Proc(AMG::Envelope, AMG::Envelope)

  def initialize(&@callback : AMG::Envelope -> AMG::Envelope); end

  def dispatch(message : AMG::Message | AMG::Envelope, stamps : Array(AMG::Stamp) = [] of AMG::Stamp) : AMG::Envelope
    @callback.call AMG::Envelope.wrap message, stamps
  end
end

struct MockMiddleware
  include AMG::Middleware::Interface

  @callback : Proc(AMG::Envelope, AMG::Middleware::StackInterface, AMG::Envelope)

  def initialize(&@callback : AMG::Envelope, AMG::Middleware::StackInterface -> AMG::Envelope); end

  def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
    @callback.call envelope, stack
  end
end
