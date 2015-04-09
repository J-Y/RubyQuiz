class FGMirror < Player
  def initialize(other)
    @player = if other["Mirror"] then
      Class.new do
        def choose() nil end
      end.new
    else
      Object.const_get(other).new(other)
    end
  end

  def choose()
    if caller[0]["in `play'"] then
      play
    else
      @player.choose
    end || rand_choice
  end

  def rand_choice()
    [:paper, :rock, :scissors].sort_by { Kernel.rand }.first
  end

  def play()
    @player.choose
  end

  def method_missing(name, *args)
    @player.send(name, *args)
  rescue Exception => err
    puts err, err.backtrace
  end
end
