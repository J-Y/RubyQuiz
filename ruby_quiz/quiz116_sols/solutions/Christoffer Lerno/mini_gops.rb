def fight(ai1_class, ai2_class)
  ai1 = ai1_class.new
  ai2 = ai2_class.new
  deck = (1..13).sort_by{ rand }.to_a
  deck1 = (1..13).to_a
  deck2 = (1..13).to_a
  points1 = 0
  points2 = 0
  while card = deck.shift
    round = 13 - deck.size
    card1 = ai1.get_card(round, card, deck1, deck2)
    card2 = ai2.get_card(round, card, deck2, deck1)
    deck1.delete card1
    deck2.delete card2
    raise "#{ai1} play corrupt (last play: #{card1})" unless deck1.size == deck.size
    raise "#{ai2} play corrupt (last play: #{card2})" unless deck2.size == deck.size
    if card1 > card2
      points1 += card
    elsif card2 > card1
      points2 += card
    end
  end
  [points1, points2]
end

def best_of_100(ai1, ai2)
  win1 = 0
  win2 = 0
  100.times do
    result = fight(ai1, ai2)
    case result[0] <=> result[1]
    when 1
      win1 += 1
    when -1
      win2 += 1
    end
  end
  [win1, win2]
end


class SimpleAi
  def get_card(round, card, deck, opponent_deck)
	  card
  end
end
