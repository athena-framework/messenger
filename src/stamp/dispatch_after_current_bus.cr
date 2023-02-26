require "./non_sendable_interface"
require "./stamp"

record Athena::Messenger::Stamp::DispatchAfterCurrentBus < Athena::Messenger::Stamp do
  include Athena::Messenger::Stamp::NonSendableInterface
end
