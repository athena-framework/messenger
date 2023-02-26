require "./non_sendable_interface"
require "./stamp"

struct Athena::Messenger::Stamp::HandlerContext < Athena::Messenger::Stamp
  include Athena::Messenger::Stamp::NonSendableInterface

  getter context : AMG::Handler::Context

  def initialize(
    @context : AMG::Handler::Context
  )
  end
end
