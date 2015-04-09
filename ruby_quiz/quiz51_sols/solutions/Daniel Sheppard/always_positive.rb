require 'rule_player'

class KnownGame
    attr_reader :deck_card_count
end

class AlwaysPositive < Player
  def initialize
    @known = KnownGame.new
    super
  end
  def show( game_data )
    @known.analyze(game_data)
  end
  def move
    #puts @known.to_s
    playable, unplayable = @known.hand.partition { |c| @known.can_play?(c) }
    suite_hash = Hash.new {|h,k|h[k] = []}
    playable.each { |c| suite_hash[c.suite] << c }
    #see if any add up to 20 or more
    suite_hands = suite_hash.values.collect {|x| x.sort_by {|c| c.score}}
    turns_remaining = (@known.deck_card_count+1)/2
    good_hands, bad_hands = suite_hands.collect do |h|
        h = h[-turns_remaining..-1] if h.size > turns_remaining
        h
    end.partition do |h|
        hand_score(h + @known.stacks[h[0].suite].mine) > 0
    end
    if @known.game_state == :draw
        good_pickups = @known.possible_pickups.select { |c|
            @known.can_play?(c) 
        }.select { |c|
            good_hand = good_hands.find {|h| h[0].suite === c.suite }
            #~ unless(good_hand)
                #~ good_hand = bad_hands.collect do |hand|
                    #~ hand = (hand + [c]).sort_by {|x| x.score}
                    #~ hand = hand[-turns_remaining..-1] if hand.size > turns_remaining
                    #~ hand
                #~ end.find do |hand|
                    #~ hand_score(hand + @known.stacks[hand[0].suite].mine) > 0
                #~ end
            #~ end
            if(good_hand)
                turns_remaining > good_hand.size || good_hand[0].score < c.score
            else
                !@known.stacks[c.suite].mine.empty?
            end
        }.sort_by { |c|
            c.score
        }
        good_pickups.empty? ? "n" : KnownGame::SUITE_KEYS.assoc(good_pickups[-1].suite)[1]
        "n"
    else
        #p turns_remaining
        if(!good_hands.empty?)
            play_hand = find_best_hand(good_hands)
            if(play_hand)
                if(turns_remaining < play_hand.size)
                    return play_hand[-turns_remaining].to_s    
                else
                    return play_hand[0].to_s    
                end
            end
        end
        return "d#{unplayable[0]}" if(!unplayable.empty?)
        return "d#{bad_hands.sort_by{|h| hand_score(h)}[0][0]}"  if(!bad_hands.empty?) 
        #should only get here during the endgame
        return "d#{good_hands[0][0]}"
    end
  end
  def hand_score(h)
      base_score = (h.inject(0) {|s, c| s + c.score } - 20) 
      score = base_score * (1 + h.select {|c| c.value === "Inv" }.size)
      score += 20 if(h.size >= 8)
      score
  end
  def lowest_remaining_score(suite, minimum=nil)
      lowest_remaining = @known.remaining_cards.select { |c| 
          c.suite === suite && (minimum.nil? || c.score > minimum)
       }.sort_by { |c| 
           c.score 
        }[0]
       lowest_remaining ? lowest_remaining.score : 11
  end
  def find_best_hand(good_hands)
    #make sure we don't have a negative stack
    in_play_unfinished = good_hands.find { |h| 
        stack = @known.stacks[h[0].suite].mine; !stack.empty? && hand_score(stack) < 0 
    }
    return in_play_unfinished if(in_play_unfinished)
    hand_scores = good_hands.collect{|h| hand_score(h)}
    turns_remaining = (@known.deck_card_count+1)/2
    if(turns_remaining < good_hands.flatten.size)
        #just go for the hand with the biggest low value
        return good_hands.sort_by { |h| h[0].score }[-1]
    else
        #find any cards that skips the least to hit the first hand
        lowest = good_hands.find { |h|
            stack = @known.stacks[h[0].suite].mine
            !stack.empty? && h[0].score < lowest_remaining_score(h[0].suite, stack[-1].score)
        }
        return lowest if lowest
        #find the hand that skips the least to hit 20
        return good_hands.sort_by do |h|
            suite = h[0].suite
            stack = @known.stacks[suite].mine
            skipped = 0
            limit = lowest_remaining_score(suite, stack.empty? ? nil : stack[-1].score)
            (0...h.size).each do |x|
                if h[x].score > limit
                    if(limit == 0)
                        skipped += @known.remaining_cards.select{|c| c.suite === suite && c.score === 0 }.size
                    else
                        skipped += (h[x].score - limit)
                        limit = lowest_remaining_score(suite, h[x].score)
                    end
                end
                break if hand_score(stack + h[0..x]) > 0
            end
            #sort on skipped, then on whether there is already a stack
            [skipped, (stack.empty? ? 1 : 0)]
        end[0]
    end
  end  
end