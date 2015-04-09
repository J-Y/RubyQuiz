class FGAttackMirror < Player
  def initialize(other)
    @player = if other["Mirror"] then
      Class.new do
        def choose() end
        def result(you, them, win_lose_or_draw) end
      end.new
    else
      Object.const_get(other).new(other)
    end
  end

  def choose()
    choice = if caller[0]["in `play'"] then
      play
    else
      @player.choose
    end || rand_choice

    attack(choice)
  end

  def attack(choice)
    case choice
      when :paper then :scissors
      when :rock then :paper
      when :scissors then :rock
    end
  end

  def rand_choice()
    [:paper, :rock, :scissors].sort_by { Kernel.rand }.first
  end

  def play()
    @player.choose
  end

  def result(you, them, win_lose_or_draw)
    @player.result(attack(you), them, win_lose_or_draw)
  end

  def method_missing(name, *args)
    @player.send(name, *args)
  rescue Exception => err
    puts err, err.backtrace
  end
end
