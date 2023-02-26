abstract struct Athena::Messenger::Message
  def self.descriptor(*, name : String? = nil, &block : self -> R) : AMG::Handler::Descriptor forall R
    AMG::Handler::Descriptor::Message(self, R).new block, name
  end

  def self.descriptor(context : C.class, *, name : String? = nil, &block : self, C -> R) : AMG::Handler::Descriptor forall C, R
    AMG::Handler::Descriptor::MessageContext(self, C?, R).new block, name
  end
end
