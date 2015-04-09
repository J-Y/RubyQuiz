# CNStepAhead: Try to think a step ahead.  If you win, use the choice
#   where you'd have lost.  If you lose, you the choice where you'd
#   have won.  Use the same on draw.

class CNStepAhead < Player
  def initialize(opponent)
    super
    @choice = [:rock, :scissors, :paper][rand(3)]
  end
  
  def choose
    @choice
  end
  
  def result(you, them, win_lose_or_draw)
    case win_lose_or_draw
    when :win
      @choice = {:rock => :paper, :paper => :scissors, :scissors => :paper}[them]
    when :lose
      @choice = {:rock => :scissors, :scissors => :paper, :paper => :rock}[you]
    end
  end
end
