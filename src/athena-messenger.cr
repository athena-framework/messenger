# This needs to be first such that the alias is available to the rest of the files.
abstract struct Athena::Messenger::Stamp; end

require "./annotations"
require "./envelope"
require "./handleable"
require "./logging"
require "./message"
require "./message_bus"

require "./handler/*"
require "./middleware/*"
require "./stamp/*"

# Convenience alias to make referencing `Athena::Messenger` types easier.
alias AMG = Athena::Messenger

alias AMGA = AMG::Annotations

module Athena::Messenger
  VERSION = "0.1.0"

  # :nodoc:
  abstract struct Container; end

  # :nodoc:
  record ValueContainer(T) < Container, value : T do
    def value_type : T.class
      T
    end

    def ==(other : AVD::Container) : Bool
      @value == other.value
    end
  end
end

Log.setup :none

record MyMessage < AMG::Message, id : Int32
record MyMessage2 < AMG::Message, id : Int32

struct MyStamp < AMG::Stamp
end

# class MyMiddleware
#   include AMG::Middleware::Interface

#   def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
#     pp "foo"

#     stack.next.handle envelope, stack
#   end
# end

# class MyMiddleware2
#   include AMG::Middleware::Interface

#   def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
#     pp "bar"

#     stack.next.handle envelope, stack
#   end
# end

# locator = AMG::Handler::Locator.new({
#   MyMessage => [descriptor],
# })

struct MyMessageHandler
  include AMG::Handler::Interface

  @[AMGA::AsMessageHandler]
  def my_message(message : MyMessage) : Int32
    message.id
  end
end

locator = AMG::Handler::Locator.new

locator.handler MyMessageHandler.new

# locator.handler MyMessage do
# end

handle_message = AMG::Middleware::HandleMessage.new locator
bus = AMG::MessageBus.new([
  AMG::Middleware::AddBusNameStamp.new("default"),
  handle_message,
] of AMG::Middleware::Interface)

# class Test
#   include AMG::Handleable(Int32)

#   def initialize(@message_bus : AMG::MessageBusInterface); end

#   def test : Int32
#     self.handle(MyMessage.new 10) * 10
#   end
# end

# t = Test.new bus

# # pp t.test

env = bus.dispatch MyMessage.new 123

# message = MyMessage.new 123
# envelope = AMG::Envelope.wrap message

# pp envelope

# e2 = envelope.with AMG::Stamp::BusName.new "Foo"

# pp envelope
# pp e2
