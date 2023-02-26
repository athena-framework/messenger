module Athena::Messenger::Handler::BatchHandlerInterface
  abstract def flush(force : Bool) : Nil
end
