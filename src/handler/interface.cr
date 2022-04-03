module Athena::Messenger::Handler::Interface
  abstract def call(message : AMG::Message) : _

  # :nodoc:
  def call(message : AMG::Message) : NoReturn
    raise "BUG:  Invoked wrong `call` overload."
  end

  protected def invoke(message : AMG::Message) : AMG::Stamp::Handled
    AMG::Stamp::Handled.new self.call(message), self.name(message)
  end

  protected def name(message : AMG::Message) : String
    "#{self.class.name}#call(#{message.class})"
  end
end
