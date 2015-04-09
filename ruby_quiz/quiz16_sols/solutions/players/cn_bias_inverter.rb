# CNBiasInverter: Choose so that your bias will be the inverted
#   opponent's bias.

class CNBiasInverter < Player
  def initialize(opponent)
    super
    @biases = {:rock => 0, :scissors => 0, :paper => 0}
    @hit = {:rock => :paper, :paper => :scissors, :scissors => :rock}
  end
  
  def choose
    n = ::Kernel.rand(@biases[:rock] + @biases[:scissors] + @biases[:paper]).to_i
    case n
    when 0..@biases[:rock]
      :paper
    when @biases[:rock]..@biases[:rock]+@biases[:scissors]
      :rock
    when @biases[:rock]+@biases[:scissors]..@biases[:rock]+@biases[:scissors]+@biases[:paper]
      :scissors
    else
      p @biases[:rock]+@biases[:scissors]..@biases[:paper]
      abort n.to_s
    end
  end
  
  def result( you, them, win_lose_or_draw )
    @biases[them] += 1
  end
end
