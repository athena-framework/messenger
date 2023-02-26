abstract struct Athena::Messenger::Stamp
  macro inherited
    {% unless @type.abstract? %}
      def_clone
    {% end %}
  end
end
