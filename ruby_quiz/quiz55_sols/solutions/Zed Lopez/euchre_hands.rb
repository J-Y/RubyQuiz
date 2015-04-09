class Euchre
  OTHER_COLOR = {'c' => 's', 's' => 'c', 'h' => 'd', 'd' => 'h'}
  attr_reader :trump_suit
  def initialize(suit_name)
    @trump_suit = suit_name
    @trump = @trump_suit[0,1].downcase
  end
  def <<(card)
    (@hand ||= []) << card
  end
  def hand
    suits = @hand.map {|card| card[1,1]}.uniq
    i = suits.index(@trump) and suits.push(suits.slice!(i))
    suits[-3],suits[-2] = suits[-2],suits[-3] if suits.length > 2 and OTHER_COLOR[suits[-1]] == suits[-2]
    @hand.sort_by do |x|
      rank, suit = x.split('')
      if rank == 'J' and @trump == suit : 50
      elsif rank == 'J' and OTHER_COLOR[suit] == @trump : 40
      else '9TJQKA'.index(rank) + suits.index(suit)*10
      end
    end.reverse
  end
end
