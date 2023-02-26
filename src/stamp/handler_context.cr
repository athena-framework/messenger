require "./non_sendable_interface"
require "./stamp"

record Athena::Messenger::Stamp::HandlerContext < Athena::Messenger::Stamp, context : AMG::Handler::Context do
  include Athena::Messenger::Stamp::NonSendableInterface
end
