# Return rank of the same color.
def opposite(rank)
  {?d => ?h,  ?h => ?d,  ?c => ?s,  ?s => ?c}.fetch rank
end

# Return rank of different color.
def neighbor(rank)
  {?d => ?c,  ?c => ?h,  ?h => ?s,  ?s => ?d}.fetch rank
end

def relative_rank(trump, suit, rank)
  case suit
  when trump:           rank == ?J ? 1000 : 500
  when neighbor(trump):                     400
  when opposite(trump): rank == ?J ?  900 : 300
  when opposite(neighbor(trump)):           200
  end +
    [?9, ?T, ?J, ?Q, ?K, ?A].index(rank)
end

def sort_cards(trump, cards)
  cards.sort_by { |c| -relative_rank(trump, c[1], c[0]) }
end

puts sort_cards(gets.strip.downcase[0], readlines.map { |s| s.strip })
