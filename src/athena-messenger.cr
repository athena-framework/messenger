# This needs to be first such that the alias is available to the rest of the files.
abstract struct Athena::Messenger::Stamp; end

require "./annotations"
require "./envelope"
require "./handleable"
require "./logging"
require "./message"
require "./message_bus"

require "./exceptions/*"
require "./handler/*"
require "./middleware/*"
require "./stamp/*"

# Convenience alias to make referencing `Athena::Messenger` types easier.
alias AMG = Athena::Messenger

# Convenience alias to make referencing `AMG::Annotations` types easier.
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

    def ==(other : AMG::Container) : Bool
      @value == other.value
    end
  end
end
