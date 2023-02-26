require "./locator_interface"

class Athena::Messenger::Handler::Locator
  include Athena::Messenger::Handler::LocatorInterface

  @handlers = Hash(AMG::Message.class, Enumerable(AMG::Handler::Descriptor)).new do |hash, key|
    hash[key] = [] of AMG::Handler::Descriptor
  end

  def handler(descriptor : AMG::Handler::Descriptor) : AMG::Handler::Descriptor
    @handlers[descriptor.message_class] << descriptor
    descriptor
  end

  def handler(message_class : M.class, name : String? = nil, &block : M -> R) : AMG::Handler::Descriptor forall M, R
    @handlers[M] << (descriptor = AMG::Handler::Descriptor::Message(M, R).new block, name)
    descriptor
  end

  def handler(message_class : M.class, context_class : C.class, name : String? = nil, &block : M, C -> R) : AMG::Handler::Descriptor forall M, C, R
    @handlers[M] << (descriptor = AMG::Handler::Descriptor::MessageContext(M, C?, R).new block, name)
    descriptor
  end

  # :inherit:
  def handler(handler : AMG::Handler::Interface) : Nil
    self.add_handler handler
  end

  private def add_handler(handler : T) : Nil forall T
    {% begin %}
      {% handlers = [] of Nil %}

      # Changes made here should also be reflected within `ADI::Messenger::CompilerPasses::RegisterHandlersPass`.
      {%
        class_handlers = T.class.methods.select &.annotation(AMGA::AsMessageHandler)

        # Raise compile time error if a handler is defined as a class method.
        unless class_handlers.empty?
          class_handlers.first.raise "Message handler methods can only be defined as instance methods. Did you mean '#{T.name}##{class_handlers.first.name}'?"
        end

        T.methods.select(&.annotation(AMGA::AsMessageHandler)).each do |m|
          # Validate the parameters of each method.
          if (m.args.size < 1) || (m.args.size > 3)
            m.raise "Expected '#{T.name}##{m.name}' to have 1..3 parameters, got '#{m.args.size}'."
          end

          message_arg = m.args[0]

          # # Validate the type restriction of the first parameter, if present
          # event_arg.raise "Expected parameter #1 of '#{T.name}##{m.name}' to have a type restriction of an 'AED::Event' instance, but it is not restricted." if event_arg.restriction.is_a?(Nop)
          # event_arg.raise "Expected parameter #1 of '#{T.name}##{m.name}' to have a type restriction of an 'AED::Event' instance, not '#{event_arg.restriction}'." if !(event_arg.restriction.resolve <= AED::Event)

          # if dispatcher_arg = m.args[1]
          #   event_arg.raise "Expected parameter #2 of '#{T.name}##{m.name}' to have a type restriction of 'AED::EventDispatcherInterface', but it is not restricted." if dispatcher_arg.restriction.is_a?(Nop)
          #   event_arg.raise "Expected parameter #2 of '#{T.name}##{m.name}' to have a type restriction of 'AED::EventDispatcherInterface', not '#{dispatcher_arg.restriction}'." if !(dispatcher_arg.restriction.resolve <= AED::EventDispatcherInterface)
          # end

          handlers << {message_arg.restriction.resolve.id, m.name.id, m.return_type.resolve.id}
        end
      %}

      {% for info in handlers %}
        {% message, method, return_type = info %}

        @handlers[{{message}}] << AMG::Handler::Descriptor::Message({{message}}, {{return_type}}).new(
          ->handler.{{method}}({{message}}),
          "{{T}}##{{{method.stringify}}}"
        )
      {% end %}
    {% end %}
  end

  def handlers(envelope : AMG::Envelope, & : AMG::Handler::Descriptor ->) : Nil
    seen = Set(String).new

    self.list_types envelope do |type|
      unless @handlers.has_key? type
        pp "no handler"
      end

      @handlers[type].each do |handler|
        yield handler
        # descriptor = AMG::Handler::Descriptor.new handler
        # next unless self.should_handle envelope, descriptor

        # name = descriptor.name
        # next unless seen.add?(name)

        # yield descriptor
      end
    end
  end

  # private def should_handle(envelope : AMG::Envelope, descriptor : AMG::Handler::Type) : Bool
  #   # TODO: Check for ReceivedStamp
  #   # TODO: Check if it should be handled by this transport

  #   true
  # end

  private def list_types(envelope : AMG::Envelope, & : AMG::Message.class ->) : Nil
    @handlers.each_key.select { |k| k <= envelope.message.class }.each do |type|
      yield type
    end
  end
end
