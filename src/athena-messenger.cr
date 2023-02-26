# This needs to be first such that the alias is available to the rest of the files.
# abstract struct Athena::Messenger::Stamp; end

require "./envelope"
require "./logging"
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
end

record MyMessage < AMG::Message, id : Int32
record MyMessage2 < AMG::Message, id : Int32

struct MyStamp < AMG::Stamp
end

struct MyMessageHandler
  include AMG::Handler::Interface

  def call(message : MyMessage) : String
    "foo"
  end
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

locator = AMG::Handler::Locator.new

locator.handler MyMessage do |msg|
  123
end

struct MyContext
  include AMG::Handler::Context
  getter name : String = "Fred"
end

locator.handler MyMessage2, MyContext? do |_, ctx|
  ctx.try(&.name) || "Bob"
end

# pp locator

# # Log.setup_from_env
Log.setup :none

middleware_iterator = AMG::Middleware::HandleMessage.new locator

# pp middleware_iterator

bus = AMG::MessageBus.new middleware_iterator
# pp bus.dispatch MyMessage.new 123

msg = MyMessage2.new 456

env = AMG::Envelope.new msg
# env << AMG::Stamp::HandlerContext.new(MyContext.new)

pp bus.dispatch(env).last(AMG::Stamp::Handled).result
# pp env
# pp env.without AMG::Stamp::Handled
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
