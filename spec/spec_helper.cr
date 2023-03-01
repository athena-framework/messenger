require "spec"

require "athena-spec"
require "../src/athena-messenger"

require "./fixtures/**"

ASPEC.run_all

struct MockMiddleware
  include AMG::Middleware::Interface

  @callback : Proc(AMG::Envelope, AMG::Middleware::StackInterface, AMG::Envelope)

  def initialize(&@callback : AMG::Envelope, AMG::Middleware::StackInterface -> AMG::Envelope); end

  def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
    @callback.call envelope, stack
  end
end
