require "./message_bus_interface"
require "./middleware/interface"

class Athena::Messenger::MessageBus
  include Athena::Messenger::MessageBusInterface

  @middleware : Enumerable(AMG::Middleware::Interface)

  # def self.new(*middleware : AMG::Middleware::Interface) : self
  #   new middleware
  # end

  def self.new(middleware : AMG::Middleware::Interface) : self
    new [middleware] of AMG::Middleware::Interface
  end

  def initialize(@middleware : Enumerable(AMG::Middleware::Interface)); end

  def dispatch(message : AMG::Message | AMG::Envelope, stamps : Array(AMG::Stamp) = [] of AMG::Stamp) : AMG::Envelope
    envelope = AMG::Envelope.wrap message, stamps

    middleware = if (m = @middleware).responds_to? :rewind
                   m.rewind
                   m
                 else
                   @middleware.dup
                 end

    stack = AMG::Middleware::Stack.new middleware

    middleware.first.handle envelope, stack
  end
end
