# CNBiasBreaker: Always use the choice that hits what the opponent
#   said most often.

class CNBiasBreaker < Player
  def initialize(opponent)
    super
    @biases = {:rock => 0, :scissors => 0, :paper => 0}
    @hit = {:rock => :paper, :paper => :scissors, :scissors => :rock}
  end
  
  def choose
    @hit[@biases.max {|a, b| a[1] <=> b[1]}.first]
  end
  
  def result( you, them, win_lose_or_draw )
    @biases[them] += 1
  end
end
