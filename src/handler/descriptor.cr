struct Athena::Messenger::Handler::Descriptor
  getter name : String
  getter handler : HandlerType

  def initialize(handler : AMG::HandlerType)
    @name = "#{handler.class.to_s}#call"
    @handler = handler
    # @handler = ->handler.call(AMG::Message)
  end
end
