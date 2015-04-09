class KnownGame
    SUITES = [:desert, :ocean, :mountains, :jungles, :volcanoes]
    SUITE_KEYS = [:desert, :ocean, :mountains, :jungles, :volcanoes].zip(%w{D O M J V})
    class CardStack
        attr_accessor :mine, :opponent, :discard
        def include?(card)
            self.piles.any? { |arr| arr.include?(card) }
        end
        def piles
            [@mine, @opponent, @discard]
        end
    end
    class Card
        include Comparable
        attr_accessor :suite, :value
        def initialize(string, suite=nil)
            if(suite)
                @suite, @value = suite, string
            else
                @value, suitestring = /(Inv|\d*)([DOMJV])/.match(string)[1..2]
                @suite = SUITE_KEYS.rassoc(suitestring)[0]
                raise "Invalid suite #{suitestring}" unless @suite
            end
        end
        def ===(other)
            @suite === other.suite && @value === other.value
        end
        alias :eql? :===
        alias :== :===
        def score
            if value === "Inv"
                0
            else
                value.to_i
            end
        end
        def <=>(other)
            self.score <=> other.score
        end
        def to_s
            (@value === "Inv" ? "I" : @value) + SUITE_KEYS.assoc(@suite)[1]
        end
    end
    attr_reader :hand, :game_state, :stacks
    def initialize
        @stacks = Hash[*SUITES.zip(Array.new(5) { CardStack.new }).flatten]
        @known_opponent_cards = []
        @opponent_card_count = 8
        @parsing_deck = nil
        @hand = nil
        @game_state = nil
    end
    def analyze(game_data)
        #~ puts "> #{game_data.chomp}"
        case game_data.strip
            when "Deserts:" : @parsing_deck = :desert
            when "Oceans:" : @parsing_deck = :ocean
            when "Mountains:" : @parsing_deck = :mountains
            when "Jungles:" : @parsing_deck = :jungles
            when "Volcanoes:" : @parsing_deck = :volcanoes
            when /Hand:(.*)/ : 
                @hand = $1.split.collect { |x| Card.new(x) }
                #~ p @hand.join(" ")
            when /(Opponent|Discards|You):(  ([^\(]*))?/ : 
                stack = @stacks[@parsing_deck]
                if $3
                    cards = $3.split.collect { |x| Card.new(x, @parsing_deck) }
                else
                    cards = []
                end
                case $1
                    when "Opponent": stack.opponent = cards
                    when "Discards": stack.discard = cards
                    when "You" : stack.mine = cards
                    else 
                        raise "Huh?"
                end
            when /You discard the (.*)\./
                @last_discard = Card.new($1).suite
            when /Deck:  #* \((\d*)\)/
                @deck_card_count = $1.to_i
            when /Your opponent discards the (.*)\./
                card = Card.new($1)
                looking = true
                @known_opponent_cards.reject! { |x| looking && !(looking = !(x === card)) }
            when /Your opponent picks up the (.*)\./
                card = Card.new($1)
                @known_opponent_cards << card
            when /^Error:/
                p game_data
                exit
            when /Draw from\?$/
                @game_state = :draw
                @remaining_cards = nil
            when /Your play\?$/
                @game_state = :play
                @last_discard = nil
                @remaining_cards = nil
            when /You play the (.*)./
            when /Your opponent plays the (.*)./
            when /You pick up the (.*)./
            when "Your opponent draws a card from the deck."
            when "You draw a card from the deck."
            else
                puts game_data.chomp
                #raise "Unknown Data"
        end
    end
    def to_s
        s = ""
        @stacks.each {|key, value|
            s << "#{key}\n"
            [:opponent, :discard, :mine].each { |a|
                s << "  #{a}:  #{value.send(a).join(" ")}\n"
            }
        }
        s << "Deck:  #{remaining_cards.join(" ")}"
        s << "Hand:  #{@hand.join(" ")}"
        s
    end
    def remaining_cards
        return @remaining_cards if @remaining_cards
        @remaining_cards = []
        SUITES.each { |suite|
            (2..10).each { |value|
                card = Card.new(value.to_s, suite)
                @remaining_cards << card unless (@stacks[suite].piles + [@known_opponent_cards, @hand]).any? { |x| x.include?(card) }
            }
            inv_count = (@stacks[suite].piles + [@known_opponent_cards, @hand]).flatten.select { |x| x === Card.new("Inv", suite) }.size
            (3 - inv_count).times { 
                @remaining_cards << Card.new("Inv", suite)
            }
        }        
        @remaining_cards
    end
    def investment_score(card)
        card.score * @stacks[card.suite].mine.inject(1) { |s,x| s = s + (card.value === "Inv" ? 1 : 0) }
    end
    def possible_pickups
        @stacks.collect { |k,v| v.discard[-1] unless k === @last_discard}.compact    
    end
    def can_play?(card, who=:mine)
        pile = @stacks[card.suite].send(who)
        return (pile.empty? || pile[-1] <= card)
    end
end

#rules accept the card and the knowledge. Should return the strength for a play, discard and draw
class RulePlayer < Player
    def initialize(rules=Rules::BasicRule.all_rules.collect { |x| x.new })
        super
        @known = KnownGame.new
        @rules = rules
    end

    def show( game_data )
        @known.analyze(game_data)
    end

    def move
        #~ puts @known.to_s
        #~ puts "Remaining:"
        #~ puts @known.remaining_cards.join(" ")
        if @known.game_state == :draw
            out = draw_card
        else
            out = make_move
        end
        #~ puts @known.to_s
        #~ p out
        #~ $stdin.gets
        out
    end

    def draw_card
        #~ possible_pickups = @known.possible_pickups
        #~ p possible_pickups
        #~ puts @known
        #~ card_scores = possible_pickups.collect { |card|
            #~ [card, @rules.inject(0) { |s, rule| s + rule.draw(card, @known) }]
        #~ }.sort_by { |x| x[1] }
        #~ best_card, best_score = card_scores[0]
        best_card, best_score = best(@known.possible_pickups, :draw)
        remaining = @known.remaining_cards
        deck_score = remaining.inject(0) { |s, card|
            s + @rules.inject(0) { |s, rule| s + rule.draw(card, @known) }
        }
        #odds of getting deck = (remaining - opposition)/2
        if(best_score.nil? || (deck_score*(remaining.length-8) >= best_score*remaining.length*2))
            "n"
        else
            #~ p best_card
            #~ p KnownGame::SUITE_KEYS.assoc(best_card.suite)[1]
            #~ puts @known.to_s
            KnownGame::SUITE_KEYS.assoc(best_card.suite)[1]
        end
    end
    def best(set, type)
        return nil if set.empty?
        scores = set.collect { |card|
            [card, @rules.inject(0) { |s, rule| s + rule.send(type, card, @known) }]
        }.sort_by { |x| -x[1] }    
        best_scores = scores.select { |x| x[1] === scores[0][1] }
        if(best_scores.size == 1)
            best_scores[0]
        else
            best_scores[rand(best_scores.size)]
        end
    end
    def make_move
        best_play = best(@known.hand.select { |x| @known.can_play?(x) }, :play)
        best_discard = best(@known.hand, :discard)
        if(best_play && best_play[1] >= best_discard[1])
            best_play[0].to_s
        else
            "d#{best_discard[0]}"
        end
        #~ possible = 
        #~ if possible.empty?
            #~ card = @known.hand.sort_by { |card|
                #~ @rules.inject(0) { |s, rule| s + rule.discard(card, @known) }
            #~ }[-1]
            #~ "d#{card}"
        #~ else
            #~ card = possible.sort_by { |card|
                #~ @rules.inject(0) { |s, rule| s + rule.play(card, @known) }
            #~ }[-1]
            #~ card.to_s
        #~ end
    end
end

module Rules
    class BasicRule
        @@rules = []
        def play(card, known) 0; end
        def discard(card, known) 0; end
        def draw(card, known) 0; end
        def self.inherited( subclass )
            @@rules << subclass
        end
        def self.all_rules
            @@rules
        end
    end
    class PlayLowestFirst < BasicRule
        def play(card, known) 
            12 - card.score
        end
    end
    #~ class MaximumScore < BasicRule
        #~ def play(card, known)
            #~ card.score * known.investment_score(card)
        #~ end
    #~ end
    class MaximumScoreEndGame < BasicRule
        def play(card, known)
            moves = (known.remaining_cards.size - 8) / 2
            if(moves > 8)
                sorted_hand = known.hand.select { |c| known.can_play?(c) }.sort_by { |c| known.investment_score(c) }
                if(sorted_hand.size < moves)
                    return 100 if sorted_hand[0] === card
                else
                    return 100 if(card === sorted_hand[-moves])
                end
            end
            return 0
        end
    end    
    class IgnoreUnusable < BasicRule
        def draw(card, known)
            known.can_play?(card) ? 0 : -100
        end
    end
    class DiscardUnusable < BasicRule
        def discard(card, known)
            known.can_play?(card) ? 0 : 1
        end
    end
    class DepriveOpponent < BasicRule
        def discard(card, known)
            known.can_play?(card, :opponent) ? -100 : 0
        end
    end
    class AvoidLateInvestment < BasicRule
        def play(card, known)
            if card.value == "Inv"
                limit = 20 * (known.stacks[card.suite].mine.size + 1)
                hand_score =  known.hand.inject(0) { |s,c|
                    s + (c.suite == card.suite ? c.score : 0)
                }
                remaining = known.remaining_cards
                deck_score = remaining.inject(0) { |s,c|
                    s + (c.suite == card.suite ? c.score : 0)
                }
                if(limit < hand_score + deck_score)
                    - 100
                else
                    0
                end
            else
                0
            end
        end
    end
    class ExpectedInvestmentValue < BasicRule
        def play(card, known)
            if card.value == "Inv"
                limit = 20 * (known.stacks[card.suite].mine.size + 1)
                hand_score =  known.hand.inject(0) { |s,c|
                    s + (c.suite == card.suite ? c.score : 0)
                }
                remaining = known.remaining_cards
                deck_score = remaining.inject(0) { |s,c|
                    s + (c.suite == card.suite ? c.score : 0)
                }
                if(limit*2*remaining.size < hand_score*2*remaining.size + (remaining.size-8)*deck_score)
                    - 100
                else
                    0
                end
            else
                0
            end
        end
    end
end


class MultiplierPlayer < RulePlayer
    class Multiplier
        def initialize(m, rule); @m,@rule = m, rule; end
        def play(card, known); @m * @rule.play(card, known); end
        def discard(card, known); @m * @rule.discard(card, known); end
        def draw(card, known); @m * @rule.draw(card, known); end            
    end
    attr_reader :multipliers
    def initialize(rule_names, multipliers)
        @multipliers = multipliers
        rules = rule_names.collect { |class_name|
            class_name.split('::').inject(Object) { |x, name| x.const_get(name) }.new
        }        
        super(
            @multipliers.zip(rules).select { |m,r|
                m && m != 0
            }.collect {|x|
                Multiplier.new(*x)
            }
        )
    end
end