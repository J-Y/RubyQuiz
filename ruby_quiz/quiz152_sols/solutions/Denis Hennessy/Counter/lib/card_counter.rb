CARDS = %w{A K Q J T 9 8 7 6 5 4 3 2}
SUITS = %w{c s h d}

class Counter
  def initialize(decks)
    @count = 4 - 4*decks
    @shoe = []
    decks.times do 
      CARDS.each do |c|
        SUITS.each do |s|
          @shoe << c.to_s + s.to_s
        end
      end
    end
    size = 52*decks
    size.times do |i|
      j = rand(size)
      @shoe[i],@shoe[j] = @shoe[j],@shoe[i]
    end
  end

  def deal
    card = @shoe.pop
    @count += 1 if "234567".include? card[0,1].to_s
    @count -= 1 if "TJQKA".include? card[0,1].to_s
    card
  end
  
  def count
    @count
  end
  
  def size
    @shoe.size
  end
end