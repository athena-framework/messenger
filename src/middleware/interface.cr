module Athena::Messenger::Middleware::Interface
  abstract def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
end
