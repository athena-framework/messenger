class Athena::Messenger::Handler::Acknowledger
  @handler_class : String
  @ack : Proc(Exception?, AMG::Container?, Nil)?
  @result_container : AMG::Container? = nil

  getter error : Exception? = nil

  def initialize(
    @handler_class : String,
    ack : Proc(Exception?, AMG::Container?, Nil)? = nil
  )
    @ack = ack || Proc(Exception?, AMG::Container?).new { }
  end

  def acknowledged? : Bool
    @ack.nil?
  end

  def ack(result : _ = nil) : Nil
    self.ack nil, result
  end

  def nack(error : Exception) : Nil
    self.ack error
  end

  def finalize : Nil
    raise "cannot be called twice" unless @ack.nil?
  end

  private def ack(exception : Exception? = nil, result : _ = nil) : Nil
    unless ack = @ack
      raise "cannot be called twice"
    end

    @ack = nil
    @error = exception
    @result_container = AMG::ValueContainer.new result

    ack.call exception, result_container
  end
end
