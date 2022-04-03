require "log"
require "json"

# This needs to be first such that the alias is available to the rest of the files.
abstract struct Athena::Messenger::Stamp
end

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

  module Handler
    alias Type = AMG::Handler::Interface # | AMG::Handler::BatchInterface
  end
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

struct Foo::MyMessageHandler
  include Athena::Messenger::Handler::Interface

  def call(message : MyMessage) : String
    pp "handling"
    "abcdefgh".chars.sample.to_s
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
    MyMessage  => ([Foo::MyMessageHandler.new] of AMG::Handler::Type),
    MyMessage2 => ([MyMessageHandler2.new] of AMG::Handler::Type),
  } of AMG::Message.class => Array(AMG::Handler::Type)
)

middleware_iterator = AMG::Middleware::HandleMessage.new locator

bus = AMG::MessageBus.new middleware_iterator

env = bus.dispatch MyMessage2.new 15

pp env
# env.without AMG::Stamp::Handled
#
# pp env

# h = env.last? AMG::Stamp::Handled
# pp h, typeof(h)

# env.all AMG::Stamp::Handled do |stamp|
#   pp stamp, typeof(stamp)
# end

# env = bus.dispatch env

# puts
# puts

# env.all AMG::Stamp::Handled do |stamp|
#   pp stamp, typeof(stamp)
# end
