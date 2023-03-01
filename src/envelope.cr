struct Athena::Messenger::Envelope
  def self.wrap(message : AMG::Message | self, stamps : Enumerable(AMG::Stamp) = [] of AMG::Stamp) : self
    envelope = message.is_a?(self) ? message : new message

    envelope.with stamps
  end

  getter message : AMG::Message

  @stamps = Hash(AMG::Stamp.class, Array(AMG::Stamp)).new

  def_clone

  def initialize(@message : AMG::Message, stamps : Enumerable(AMG::Stamp) = [] of AMG::Stamp)
    stamps.each do |stamp|
      self.add @stamps, stamp
    end
  end

  def with(stamp : AMG::Stamp) : self
    self.with({stamp})
  end

  def with(*stamps : AMG::Stamp) : self
    self.with stamps
  end

  def with(stamps : Enumerable(AMG::Stamp))
    cloned = self.clone

    stamps.each do |stamp|
      self.add cloned.@stamps, stamp
    end

    cloned
  end

  def without(stamp_type : T.class) : self forall T
    self.without { |stamp_class| stamp_class <= T }
  end

  def without(& : AMG::Stamp.class -> Bool) : self
    cloned = self.clone

    cloned.@stamps.each_key do |stamp_class|
      cloned.@stamps.delete stamp_class if yield stamp_class
    end

    cloned
  end

  def last(stamp_type : T.class) : T forall T
    @stamps[stamp_type].last.as T
  end

  def last?(stamp_type : T.class) : T? forall T
    @stamps[stamp_type]?.try &.last.as? T
  end

  def all : Hash(AMG::Stamp.class, Array(AMG::Stamp))
    @stamps
  end

  def all(stamp_type : T.class) : Array(T) forall T
    return [] of T unless (stamps = @stamps[stamp_type]?)

    stamps.map &.as T
  end

  def all(stamp_type : T.class, & : T ->) : Nil forall T
    @stamps[stamp_type]?.try &.each do |stamp|
      yield stamp.as T
    end
  end

  def all(& : AMG::Stamp ->) : Nil
    @stamps.each_value do |stamps|
      stamps.each do |stamp|
        yield stamp
      end
    end
  end

  # TODO: Remove when/if https://github.com/crystal-lang/crystal/issues/13128 is resolved.
  @[AlwaysInline]
  private def add(stamps : Hash(AMG::Stamp.class, Array(AMG::Stamp)), stamp : AMG::Stamp) : Nil
    (stamps[stamp.class] ||= [] of AMG::Stamp) << stamp
  end
end
