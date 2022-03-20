require "./envelope"
require "./message_interface"
require "./message_bus"

require "./middleware/*"
require "./stamp/*"

# Convenience alias to make referencing `Athena::Messenger` types easier.
alias AMG = Athena::Messenger

module Athena::Messenger
  VERSION = "0.1.0"
end

struct MyMessage
  include AMG::MessageInterface
end

struct MyStamp < AMG::Stamp
end

class MyHandler
  include AMG::Middleware::Interface

  def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
    pp "foo"

    stack.next.handle envelope, stack
  end
end

class MyHandler2
  include AMG::Middleware::Interface

  def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
    pp "bar"

    stack.next.handle envelope, stack
  end
end

bus = AMG::MessageBus.new [MyHandler.new, MyHandler2.new] of AMG::Middleware::Interface

bus.dispatch MyMessage.new
