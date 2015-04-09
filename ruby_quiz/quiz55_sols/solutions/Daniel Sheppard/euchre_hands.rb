class Card
    attr_reader :suite, :value
    def initialize(string)
        @value = string[0..-2].upcase
        @suite = string[-1..-1].downcase
    end
    def to_i
        %w{9 T J Q K A}.index(@value)
    end
    def to_s
        @value + @suite
    end
end
class EuchreHand
    def initialize(trump, cards)
        @trump_string = trump
        @trump = trump[0..0].downcase
        @cards = cards
        same, opposite = [['h','d'],['c','s']].partition {|x| x.include?(@trump)}
        @same = same.flatten.reject{|s| s == @trump}[0]
        opposite = opposite.flatten.select {|s| cards.any?{|c| c.suite == s}}
        @suite_order = [@trump, @same].zip(opposite).flatten
    end
    def to_s
        ([@trump_string] +sorted_cards).join("\n")
    end
    def sorted_cards
        @cards.sort_by {|c| sort_value(c)}
    end
    private
    #there are 6 sections of the sort: jack1, jack2, trump, opp1, same, opp2
    def sort_value(card)
        return [0] if card.value == 'J' && card.suite == @trump
        return [1] if card.value == 'J' && card.suite == @same
        return [2+@suite_order.index(card.suite),-card.to_i]
    end
end

cards = ARGF.readlines 
#~ cards = %w{Diamonds Ah Jd Jh Kc 9c}
puts EuchreHand.new(cards.shift, cards.map {|s| Card.new(s)})
