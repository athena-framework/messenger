struct Athena::Messenger::Envelope
  def self.wrap(message : AMG::Message | self, stamps : Enumerable(AMG::Stamp) = [] of AMG::Stamp) : self
    envelope = message.is_a?(self) ? message : new message

    envelope << stamps

    envelope
  end

  getter stamps = Hash(AMG::Stamp.class, Array(AMG::Stamp)).new
  getter message : AMG::Message

  def initialize(@message : AMG::Message, stamps : Enumerable(AMG::Stamp) = [] of AMG::Stamp)
    stamps.each do |stamp|
      (@stamps[stamp.class] ||= Array(AMG::Stamp).new) << stamp
    end
  end

  def <<(*stamps : AMG::Stamp) : Nil
    self.<< stamps
  end

  def <<(stamps : Enumerable(AMG::Stamp)) : Nil
    stamps.each do |stamp|
      (@stamps[stamp.class] ||= Array(AMG::Stamp).new) << stamp
    end
  end

  def all(stamp_type : T.class, & : T -> Nil) forall T
    @stamps[stamp_type]?.try &.each do |stamp|
      yield stamp.as T
    end
  end

  def all(& : AMG::Stamp -> Nil)
    @stamps.each_value do |stamps|
      stamps.each do |stamp|
        yield stamp
      end
    end
  end

  def last(stamp_type : T.class) : AMG::Stamp forall T
    @stamps[stamp_type].last.as T
  end

  def last?(stamp_type : T.class) : AMG::Stamp? forall T
    @stamps[stamp_type]?.try &.last.as T
  end

  def without(stamp_type : T.class) : Nil forall T
    self.without { |stamp_class| stamp_class <= T }
  end

  def without(& : AMG::Stamp.class -> Bool) : Nil
    @stamps.each_key do |stamp_class|
      @stamps.delete stamp_class if yield stamp_class
    end
  end
end
