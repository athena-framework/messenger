abstract struct Athena::Messenger::Stamp; end

struct Athena::Messenger::Stamp::Handled < Athena::Messenger::Stamp
  @result_container : Container
  getter handler_name : String

  def initialize(result : _, @handler_name : String)
    @result_container = ValueContainer.new result
  end

  def result
    @result_container.value
  end
end
