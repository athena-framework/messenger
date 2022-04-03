abstract struct Athena::Messenger::Stamp; end

struct Athena::Messenger::Stamp::Handled < Athena::Messenger::Stamp
  @result_container : Container
  getter handler_name : String

  def initialize(@result_container : AMG::Container, @handler_name : String); end

  def self.new(result : _, handler_name : String)
    new AMG::ValueContainer.new(result), handler_name
  end

  def result
    @result_container.value
  end

  def result(as type : T.class) : T forall T
    self.result.as T
  end
end
