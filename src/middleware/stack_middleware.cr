class Athena::Messenger::Middleware::Stack
  include Athena::Messenger::Middleware::Interface
  include Athena::Messenger::Middleware::StackInterface

  private struct MiddlewareStack
    property iterator : Iterator(AMG::Middleware::Interface)? = nil
    getter stack : Array(AMG::Middleware::Interface) = [] of AMG::Middleware::Interface

    def next(offset : Int) : AMG::Middleware::Interface?
      if middleware = @stack[offset]?
        return middleware
      end

      return unless (iterator = @iterator)

      middleware = iterator.next

      if middleware.is_a? Iterator::Stop
        return @iterator = nil
      end

      @stack << middleware

      middleware
    end
  end

  @stack : MiddlewareStack
  @offset = 0

  def initialize(middleware : Enumerable(AMG::Middleware::Interface) | AMG::Middleware::Interface)
    @stack = MiddlewareStack.new

    case middleware
    in AMG::Middleware::Interface then @stack.stack << middleware
    in Enumerable                 then @stack.iterator = middleware.each
    in Iterator                   then @stack.iterator = middleware
    end
  end

  def next : AMG::Middleware::Interface
    unless next_middleware = @stack.next @offset
      return self
    end

    @offset += 1

    next_middleware
  end

  def handle(envelope : AMG::Envelope, stack : AMG::Middleware::StackInterface) : AMG::Envelope
    envelope
  end
end
