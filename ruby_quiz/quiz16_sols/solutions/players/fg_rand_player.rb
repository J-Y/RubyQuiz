class FGRandPlayer < Player
  def choose
    [:paper, :rock, :scissors][rand(3)]
  end
end
