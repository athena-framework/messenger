require "log"

require "./envelope"
require "./message"
require "./message_bus"

require "./handler/*"
require "./middleware/*"
require "./stamp/*"

# Convenience alias to make referencing `Athena::Messenger` types easier.
alias AMG = Athena::Messenger

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

  alias HandlerType = AMG::Handler::Interface # | Proc(AMG::Message)
end

record MyMessage < AMG::Message, id : Int32
record MyMessage2 < AMG::Message, id : Int32

struct MyStamp < AMG::Stamp
end

struct MyMessageHandler
  include Athena::Messenger::Handler::Interface

  def call(message : MyMessage) : String
    "foo"
  end
end

class MyMiddleware
  include AMG::Middleware::Interface

  def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
    pp "foo"

    stack.next.handle envelope, stack
  end
end

class MyMiddleware2
  include AMG::Middleware::Interface

  def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
    pp "bar"

    stack.next.handle envelope, stack
  end
end

struct MyMessageHandler
  include Athena::Messenger::Handler::Interface

  def call(message : MyMessage) : String
    "foo"
  end
end

struct MyMessageHandler2
  include Athena::Messenger::Handler::Interface

  def call(message : MyMessage2) : Int32
    123
  end
end

locator = AMG::Handler::Locator.new(
  {
    MyMessage  => ([MyMessageHandler.new] of AMG::HandlerType),
    MyMessage2 => ([MyMessageHandler2.new] of AMG::HandlerType),
  } of AMG::Message.class => Array(AMG::HandlerType)
)

middleware_iterator = AMG::Middleware::HandleMessage.new locator

bus = AMG::MessageBus.new middleware_iterator

env = bus.dispatch MyMessage.new 15
result = env.last(AMG::Stamp::Handled).result String # => "foo" : String
pp result, typeof(result)

# env = bus.dispatch MyMessage2.new 20
# result = env.last(AMG::Stamp::Handled).result # => "foo" : String
# pp result, typeof(result)
