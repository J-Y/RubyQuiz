# Constants
RANKS = 'AKQJT9'
SUITS = 'SHCD'

def euchre_sort(cards)
  # Split out trump
  trump = cards.shift

  # Quick and dirty validation
  trump_index = SUITS.index(trump[0,1].upcase)
  unless trump_index
    puts "Invalid trump (#{trump})."
    exit
  end
  cards.each do |card|
    if card !~ /^[#{RANKS}][#{SUITS}]$/i
      puts "Invalid card (#{card})."
      exit
    end
  end

  # Return sorted hand
  right_bower = "J#{SUITS[trump_index,1]}"
  left_bower = "J#{SUITS[trump_index - 2,1]}"
  [trump] +
    cards.sort_by do |card|
      upcase_card = card.upcase
      case upcase_card
        when right_bower then -2
        when left_bower  then -1
        else RANKS.index(upcase_card[0,1]) +
          10 * ((SUITS.index(upcase_card[1,1]) - trump_index) % 4)
      end
    end
end

puts euchre_sort(STDIN.read.split)
