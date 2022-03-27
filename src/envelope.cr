struct Athena::Messenger::Envelope
  def self.wrap(message : AMG::Message | self, stamps : Enumerable(AMG::Stamp) = [] of AMG::Stamp) : self
    envelope = message.is_a?(self) ? message : new message

    envelope << stamps

    envelope
  end

  @stamps = Hash(AMG::Stamp.class, Array(AMG::Stamp)).new
  getter message : AMG::Message

  def initialize(@message : AMG::Message, stamps : Enumerable(AMG::Stamp) = [] of AMG::Stamp)
    stamps.each do |stamp|
      (@stamps[stamp.class] ||= Array(AMG::Stamp).new) << stamp
    end
  end

  def last(stamp_type : T.class) : AMG::Stamp forall T
    @stamps[stamp_type].last.as T
  end

  def <<(*stamps : AMG::Stamp) : Nil
    self.<< stamps
  end

  def <<(stamps : Enumerable(AMG::Stamp)) : Nil
    stamps.each do |stamp|
      (@stamps[stamp.class] ||= Array(AMG::Stamp).new) << stamp
    end
  end
end
