class EuchreHand
  SUIT = [?c,?d,?s,?h]
  VAL = [?A,?K,?Q,?J,?T,?9]
  def initialize input
    @trump = input.shift
    @hand = {}
    4.times {|s| @hand[SUIT[s]]=[]}
    input.each{|card| @hand[card[1]] << card[0] }
  end
  def display
    puts @trump
    t=SUIT.index(@trump.downcase[0])
    get_jacks(SUIT[t])
    get_jacks(SUIT[(t+2)%4])
    if @hand[SUIT[(t+1)%4]].empty?
      t.downto(0){|s| show_suit s}
      (3).downto(t+1) {|s| show_suit s}
    else
      (t..3).each {|s| show_suit s}
      (0...t).each {|s| show_suit s}
    end
  end
  def get_jacks suit
    if @hand[suit].include? ?J
      puts [?J,suit].pack('c*')
      @hand[suit].delete(?J)
    end
  end
  def show_suit s
    suit = SUIT[s]
    @hand[suit].sort{|a,b| VAL.index(a)<=>VAL.index(b)}.each{|v|
      puts [v,suit].pack('c*')
    }
  end
end

if __FILE__ == $0
  input =readlines
  e = EuchreHand.new(input)
  e.display
end
