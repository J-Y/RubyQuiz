SYMBOLS = [ :rock,
           :paper,
           :scissors ]
KILLER = { :rock => :paper, :paper => :scissors, :scissors => :rock }

class BHCheatPlayer < Player

  def initialize( opponent )
    super
    @opp = Object.const_get(opponent).new(self)
  end

  def choose
    KILLER[@opp.choose]
  end

  def result(you,them,result)
    @opp.result(them,you,result)
  end

end
