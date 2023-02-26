# This needs to be first such that the alias is available to the rest of the files.
abstract struct Athena::Messenger::Stamp; end

require "./annotations"
require "./envelope"
require "./handleable"
require "./logging"
require "./message"
require "./message_bus"

require "./handler/*"
require "./middleware/*"
require "./stamp/*"

# Convenience alias to make referencing `Athena::Messenger` types easier.
alias AMG = Athena::Messenger

alias AMGA = AMG::Annotations

module Athena::Messenger
  VERSION = "0.1.0"

  # :nodoc:
  abstract struct Container; end

  # :nodoc:
  record ValueContainer(T) < Container, value : T do
    def value_type : T.class
      T
    end

    def ==(other : AVD::Container) : Bool
      @value == other.value
    end
  end
end
