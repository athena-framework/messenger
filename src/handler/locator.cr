require "./locator_interface"

class Athena::Messenger::Handler::Locator
  include Athena::Messenger::Handler::LocatorInterface

  @handlers : Hash(AMG::Message.class, Array(AMG::Handler::Type))

  def initialize(@handlers : Hash(AMG::Message.class, Array(AMG::Handler::Type))); end

  def handlers(envelope : AMG::Envelope, & : AMG::Handler::Type ->) : Nil
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

  private def should_handle(envelope : AMG::Envelope, descriptor : AMG::Handler::Type) : Bool
    # TODO: Check for ReceivedStamp
    # TODO: Check if it should be handled by this transport

    true
  end

  private def list_types(envelope : AMG::Envelope, & : AMG::Message.class ->) : Nil
    @handlers.each_key.select { |k| k <= envelope.message.class }.each do |type|
      yield type
    end
  end
end
