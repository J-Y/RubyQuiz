class EuchreCard

    SUIT_COLOR = {
        :diamonds => :red,
        :hearts => :red,
        :clubs => :black,
        :spades => :black
    }
    SUIT_ORDER = [:diamonds, :clubs, :hearts, :spades]
    RANK_ORDER = [:nine, :ten, :jack, :queen, :king, :ace]

    attr_reader :rank, :suit

    def initialize(str)
        str = str.to_s.downcase
        @rank =
            if str[0] == ?9
                :nine
            else
                RANK_ORDER.find { |rank| rank.to_s[0] == str[0] }
            end
        @suit = SUIT_ORDER.find { |suit| suit.to_s[0] == str[1] }
        raise "unknown card rank" unless rank
        raise "unknown card suit" unless suit
    end

    def to_s
        unless rank == :nine
            rank.to_s[0, 1].upcase
        else
            "9"
        end + suit.to_s[0, 1]
    end

    def sort_score(trump)
        if rank == :jack && suit == trump
            0
        elsif rank == :jack && SUIT_COLOR[suit] == SUIT_COLOR[trump]
            1
        else
            ti = SUIT_ORDER.index(trump)
            raise "unknown trump suit: #{trump}" unless ti
            suit_score = (SUIT_ORDER.index(suit) - ti) % 4
            10 + suit_score * 10 - RANK_ORDER.index(rank)
        end
    end
end

if $0 == __FILE__
    trump = gets.strip.downcase.to_sym
    unless EuchreCard::SUIT_COLOR.has_key? trump
        warn "unknown trump suit: #{trump}"
        exit 1
    end
    cards = readlines.map { |line| EuchreCard.new(line.strip) }
    cards = cards.sort_by { |card| card.sort_score(trump) }
    puts trump.to_s.capitalize, cards
end
