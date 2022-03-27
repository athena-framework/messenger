module Athena::Messenger::MessageBusInterface
  abstract def dispatch(message : AMG::MessageInterface | AMG::Envelope, stamps : Array(AMG::Stamp) = [] of AMG::Stamp) : AMG::Envelope
end
