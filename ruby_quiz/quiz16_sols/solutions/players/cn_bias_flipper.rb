# CNBiasFlipper: Always use the choice that hits what the opponent
#   said most or second-to-most often (if the most often choice is not
#   absolutely prefered).

class CNBiasFlipper < Player
  def initialize(opponent)
    super
    @biases = {:rock => 0, :scissors => 0, :paper => 0}
    @hit = {:rock => :paper, :paper => :scissors, :scissors => :rock}
  end
  
  def choose
    b = @biases.sort_by {|k, v| -v}
    if b[0][1] > b[1][1]*1.5
      @hit[b[0].first]
    else
      @hit[b[1].first]
    end
  end
  
  def result( you, them, win_lose_or_draw )
    @biases[them] += 1
  end
end
