#!/usr/local/bin/ruby -w

#ADS_lc_player.rb
#  -Adam Shelly 10.17.05
#
# Player for 'lost_cities.rb' from Ruby Quiz #51
#
# runs a whole bunch of rules classifying cards.
# multiplies rules by weights to rank ranks cards in hand along 2 axis :  
#   keep->discard(1..-1) and   play->hold(1..-1)
# makes best play from the rankings.

require 'Matrix'
require 'Yaml'

class Array
    def max_index
        index max 
    end
end


class ADS_LC_Player < Player
    S = {?D=>0,?O=>1,?M=>2,?J=>3,?V=>4}
    attr_reader :winner
    def initialize
        super
        @name="1a"
        @myhand =[] 
        @land=Array.new(5){Array.new}
        @opplands=Array.new(5){Array.new}
        @dpile = Array.new(5){Array.new}
        @data = ""
        @deckcount = 12*5-16
        @discarded = 0
        #rules affecting play/hold decision : 
        #positive values mean play, negative mean hold
        @prules = {:rule_inSequence=>[0.6,0.8], 
                   :rule_lowCard=>[0.1,0.0], 
                   :rule_lowCards=>[0.2,0.0], 
                   :rule_highCard=>[-0.3,0.1], 
                   :rule_highCards=>[-0.2,0.2], 
                   :rule_investments=>[0.1,-0.2], 
                   :rule_onInvestments=>[0.5,0.7],
                   :rule_holdingInvestments=>[-0.2,0.0],
                   :rule_investmentWithHope=>[0.5,0.3],
                   :rule_investmentWithoutHope=>[-0.6,-1.0],
                   :rule_group10=>[0.5,-0.4], 
                   :rule_group15=>[0.6,-0.3], 
                   :rule_group20=>[0.7,-0.2], 
                   :rule_group25=>[0.9,-0.1], 
                   :rule_total20 =>[0.35,1.0], 
                   :rule_total25 =>[0.6,1.0], 
                   :rule_suitStarted=>[0.7,0.9],
                   :rule_closeToPrevious=>[0.4,0.5], 
                   :rule_multiplier2=>[0.4,0.8],
                   :rule_multiplier3=>[0.5,0.9],
                   :rule_onUnplayed=>[-0.5,-1.0],
                   :rule_heHasPlayed=>[-0.1,0.0],
                   :rule_heHasPlayed10=>[-0.2,0.0],
                   :rule_heHasPlayed20=>[-0.3,0.0],
                   :rule_handNegative=>[0.5,0.9],
                   :rule_mustPlays=>[-0.3,1.0],
                   :rule_lowerInHand=>[-0.5,-0.4],
                   :rule_highestInHand=>[-0.1,-0.01],
                   :rule_2followsInvest=>[0.3,0.5],
                   :rule_finishGame=>[0.0,2.0],
                   :rule_possibleBelow=>[-0.2,-0.05],
                   :rule_possibleManyBelow=>[-0.4,-0.1]}
        #rules affecting keep/discard decision : 
        #positive values mean keep, negative mean discard
        @drules = {:rule_useless2me=>[-0.5, 0.1],
                   :rule_useless2him=>[-0.2,0.1],
                   :rule_useful2him=>[0.4,0.5], 
                   :rule_useful2me=>[0.3,0.3],
                   :rule_heHasPlayed=>[0.1,0.3],
                   :rule_singleton=>[-0.2,-0.1],
                   :rule_noPartners=>[-0.3,-0.3],
                   :rule_wantFromDiscard=>[0.3,0.5],
                   :rule_belowLowestPlayable=>[-0.2,0.0],
                   :rule_dontDiscardForever=>[0.5,1]}
    end

    def load filename=nil
        if (filename)
            g = Gene.load(filename)
            @prules = g.prules.merge(@prules)
            @drules = g.drules.merge(@drules)
            @name = g.name
        end
    end
        
    def show( game_data )
        #replace Inv w/ '0' and 10 with ':' (= ?9+1)
        game_data.gsub!(/Inv/,'0')
        game_data.gsub!(/10(\w)/,':\1')   
        case game_data 
            when  /Hand:  (.+?)\s*$/
                @oldhand = @myhand
                @myhand = $1.split 
            when /^Your opponent plays the (.*)\./
                push @opplands, $1
            when /^Your opponent discards the (.*)\./
               push @dpile, $1
            when /opponent draws/
               @deckcount-=1
            when /opponent picks up the (.*)\./
               @dpile[suit($1)].pop 
            when /Final Score:(.*)\(Y.*vs.(.*)\(Op/
                p "Game Over, #{$1} vs #{$2}" 
                @winner = $1.to_i > $2.to_i
                #Gene.new(@prules,@drules,@name).dump "#{@name}.yaml"
        end
        @data << game_data
    end

    def move
        if @data.include?("Draw from?")
            draw_card
        else
            make_move.sub(/0/, "I").sub(":","10")
        end
        ensure
        @data = ""
    end

    private

    def suit card
        S[card[-1]]
    end
    def val card
        card[-2]-?0
    end
    def push pile,card
        pile[suit(card)]<<val(card)
    end

    def draw_card
        @dwanted.each_with_index{|w,i|
            if w 
                @dpile[i].pop
                return [S.index(i)].pack("C") 
            end
        }
        @deckcount-=1
        "n"
    end
         
    def calc_statistics
        # find out interesting facts about cards
        @set_held=Array.new(5){Array.new}
        @sumheld = Array.new(5){0}
        @multiples = Array.new(5){1}
        @iplayed = Array.new(5){0}
        @lowest_playable = Array.new(5)
        @unseen = Array.new(5){(2..10).to_a}

        @myhand.each(){|c| 
            @set_held[suit(c)] << val(c)
            @sumheld[suit(c)]+=val(c) 
            @multiples[suit(c)]*=2 if val(c)==0 
        }
        @land.each_with_index {|l,i| l.each{|v| 
            @multiples[i]*=2 if v==0 
            @iplayed[i]+=1 if v==0 
            @unseen[i].delete v
        }}
        @opplands.each_with_index{|l,i| l.each{|v|
            @unseen[i].delete v
        }}
        @dpile.each_with_index{|l,i| l.each{|v|
            @unseen[i].delete v
        }}
        @sumplayed = @land.map{|l| l.inject(0){|sum,v|sum+=v}}
        @opplayed = @opplands.map{|l| l.inject(0){|sum,v|sum+=v}}
        5.times {|i| 
            @lowest_playable[i] = [@land[i][-1]||0,@opplands[i][-1]||0].min  
        }

        #we must play any valid cards we are holding in a suit we have started
        @mustplay = @myhand.find_all{|c| val(c) >= (@land[suit(c)][-1]||11) }
        #time running out?
        @tight = ((@deckcount /2)-1 <= @mustplay.size) ? 1 : 0
        @supertight = ((@deckcount) <= @mustplay.size) 
    end
         
    def check_discards 
        #prevent endless loop of discards
        return @dwanted = [nil]*5 if @discarded > 5
        i=-1
        # find cards we can play, or cards we can probably use 
        @dwanted = @dpile.map do |p|  
            i+=1
            (card = p[-1]) &&
            if (l = @land[i][-1])
                card && (card >= l)                        #we can use for sure
            else
                card + @sumheld[i] > 15 && @tight==0       #we can probably use
            end
        end
        #if we need more time for 'mustplay' cards, force draw from discard
        if @supertight  && (@dwanted.find_all{|d|d}==[]) 
            @dwanted = @dpile.map{|p| p[-1] }
        end
    end

    def make_move
        calc_statistics
        check_discards
        p @opplands,@dpile,@land,@myhand if $DEBUG
        
        #Rank Play<->Hold and Keep<->Discard
        pmoves,dmoves = Moveset.new,Moveset.new
        @prules.each {|rule,weights| pmoves += apply(rule) * weights[@tight]}
        @drules.each {|rule,weights| dmoves += apply(rule) * weights[@tight]}
        
        #We want to play the ones with high Play and low Keep values
        possible_plays = pmoves - dmoves*0.5
        #we want to discard the ones with high Discard and low Hold values
        possible_discards = (pmoves*0.5 - dmoves)
        p possible_plays, possible_discards if $DEBUG

        while 1
            if possible_plays.max >= possible_discards.max
                play= @myhand[possible_plays.max_index]
                p "#{possible_plays.max} vs #{possible_discards.max} => #{play}" if $DEBUG
                if play_valid?(play)
                    push @land, play
                    @discarded = 0
                    return play
                else  #take invalid plays out of the running
                    mi = possible_plays.max_index
                    (possible_plays = possible_plays.to_a)[mi]=-100
                    next
                end
            else 
                play= @myhand[possible_discards.max_index]
            end
            p "discarding #{play}" if $DEBUG
            push @dpile, play
            @dwanted[suit(play)]=nil  #we can't draw from here
            @discarded += 1
            return "d#{play}"
        end
    end

    def play_valid? play
        hi =@land[suit(play)][-1]
        !hi || (val(play) >=hi)
    end
        
    def apply rule
        a = @myhand.map {|c| self.send(rule,c) ? 1 : 0 }
        p "#{a.inspect} <#{rule}: " if $DEBUG
        Moveset.new(a)
    end
    
    #All the ways to classify a card.
    def rule_inSequence c
         val(c) == ((@land[suit(c)][-1]||-1) +1 )
    end
    def rule_2followsInvest c
        val(c) == 2 && @iplayed[suit(c)] > 0
    end
    def rule_lowCard c
        c == @myhand.min
    end
    def rule_lowCards c
        val(c) < 5
    end
    def rule_highCard c
        c == @myhand.max
    end
    def rule_highCards c
        val(c) > 5
    end
    def rule_investments c
        val(c) == 0
    end
    def rule_onInvestments c
        @land[suit(c)].include?(0)
    end
    def rule_holdingInvestments c
        @set_held[suit(c)].include?(0) && val(c) != 0
    end
    def rule_group10 c
        @sumheld[suit(c)] > 10
    end
    def rule_group15 c
        @sumheld[suit(c)] > 15
    end
    def rule_group20 c
        @sumheld[suit(c)] > 25
    end
    def rule_group25 c
        @sumheld[suit(c)] > 25
    end
    def rule_total20 c
        @sumheld[suit(c)]+@sumplayed[suit(c)] > 21
    end
    def rule_total25 c
        @sumheld[suit(c)]+@sumplayed[suit(c)] > 25
    end
    def rule_investmentWithHope c
        val(c) == 0 && ( @sumheld[suit(c)] > (5 + 5*@multiples[suit(c)]))
    end
    def rule_investmentWithoutHope c
        !rule_investmentWithHope c
    end
    def rule_suitStarted c
        @sumplayed[suit(c)]+ @iplayed[suit(c)] > 0
    end
    def rule_closeToPrevious c
        (val(c) - (@land[suit(c)][-1]||0))  < 3
    end
    def rule_useless2me c
        val(c) < ( @land[suit(c)][-1] || 0)
    end
    def rule_useful2me c
        val(c) >= ( @land[suit(c)][-1] || 10)
    end
    def rule_useless2him c
        val(c) < ( @opplands[suit(c)][-1] || 0 )
    end
    def rule_useful2him c
        val(c) >= ( @opplands[suit(c)][-1] || 0 )
    end
    def rule_possibleBelow c
        @unseen[suit(c)].find_all{|v| v < val(c)}.size > 0
    end
    def rule_possibleManyBelow c
        @unseen[suit(c)].find_all{|v| v < val(c)}.size > 3
    end
    def rule_multiplier2 c
        @multiples[suit(c)]>2
    end
    def rule_multiplier3 c
        @multiples[suit(c)]>4
    end
    def rule_onUnplayed c
        @land[suit(c)].empty?
    end
    def rule_heHasPlayed c
        !@opplands[suit(c)].empty?
    end
    def rule_heHasPlayed10 c
        @opplayed[suit(c)] > 10
    end
    def rule_heHasPlayed20 c
        @opplayed[suit(c)] > 20
    end
    def rule_singleton c
        @set_held[suit(c)].size == 1
    end
    def rule_noPartners c
        @land[suit(c)].empty?
    end
    def rule_handNegative c
        !@land[suit(c)].empty? &&@sumplayed[suit(c)] < 20
    end
    def rule_wantFromDiscard c
        @dwanted[suit(c)]
    end
    def rule_mustPlays c
        @mustplay.include?(c)
    end
    def rule_belowLowestPlayable c
        val(c) < @lowest_playable[suit(c)]
    end
    def rule_lowerInHand c
        val(c) > @set_held[suit(c)].min
    end 
    def rule_highestInHand c
        val(c) == @set_held[suit(c)].max
    end 
    def rule_finishGame c
        #tag the ones we need to play
        @supertight  && @mustplay.include?(c)
    end
    def rule_dontDiscardForever c
        @discarded > 5
    end
    
        
end

# A moveset is simply a set of rankings for each move.
# They can be added, multiplied by scalars, etc.
# This probably should have been a subclass of Vector, instead of containing one...
class Moveset
    def initialize source = nil
        @moves = source ? Vector[*(source.to_a)] : Vector[*Array.new(8){0}]
    end
    def * other
        Moveset.new(@moves * other)
    end
    def + other
        Moveset.new(@moves + Vector[*(other.to_a)])
    end
    def - other
        Moveset.new(@moves - Vector[*(other.to_a)])
    end
    def [] idx
        @moves[index]
    end
    def []= idx,val
        @moves[index] = val
    end
    def max
        @moves.to_a.max
    end
    def max_index
        @moves.to_a.index max 
    end
    def to_a
        @moves.to_a
    end
    def to_s
        @moves.to_s
    end
end

#A container for all the rules.
# Allows easy yamlization.
class Gene
    attr_reader :prules, :drules
    attr_accessor :name, :parent
    def initialize p,d,n,par=nil
        @prules = p
        @drules = d
        @name = n
        @parent = par
    end
    def dump filename
        File.open( filename, 'w' ) {|f| f<<self.to_yaml}
    end
    def Gene.load filename
       File.open(filename){|f| YAML::load(f)}
    end
end
