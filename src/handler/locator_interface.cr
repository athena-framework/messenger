module Athena::Messenger::Handler::LocatorInterface
  abstract def handlers(envelope : AMG::Envelope, & : AMG::Handler::Descriptor ->) : Nil
end
