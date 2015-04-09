#!/usr/local/bin/ruby -w

# Global mappings of cards to numbers
$values = { "A" => 1,
            "2" => 2,
            "3" => 3,
            "4" => 4,
            "5" => 5,
            "6" => 6,
            "7" => 7,
            "8" => 8,
            "9" => 9,
            "T" => 10,
            "J" => 11,
            "Q" => 12,
            "K" => 13,
            "X" => 14  # this is an ace high, as opposed to ace low
          }

# Just to make things pretty -- but Six plural i don't handle
$strs = { "A" => "Ace",
          "2" => "Two",
          "3" => "Three",
          "4" => "Four",
          "5" => "Five",
          "6" => "Six",
          "7" => "Seven",
          "8" => "Eight",
          "9" => "Nine",
          "T" => "Ten",
          "J" => "Jack",
          "Q" => "Queen",
          "K" => "King"
        }

# This is the class that handles everything for us.  Holds onto the hand
# and classifies it
class Classifier

  attr_reader :rank, :folded, :goods, :type, :kickers
  attr_accessor :winner

  def initialize(hand)
    @hand = hand
    @goods = []
    @folded = false
    @winner = false
    @type = ""
  end

  # Just sorts the goods
  def sortgoods
    @goods = @goods.flatten.sort { |x, y|
      $values[x[0].chr] <=> $values[y[0].chr]
    }
  end

  # run through the possibles in order of "goodness" and classify the hand
  # in its best possible light.  Yes, this recomputes things sometimes, but
  # who cares?
  def classify
    # Store both kickers.  We do this so that we can eliminate one if
    # necessary on the high card scenario
    @kickers = @hand[0..1].map { |x|
      if x[0].chr == "A"
        "X" + x[1].chr
      else
        x
      end
    }.sort { |x, y|
      $values[x[0].chr] <=> $values[y[0].chr]
    }.map { |x| $values[x[0].chr] }.reverse
    # Player chickened out, so quit.  We assume that if there are 7 cards
    # then they went all the way.
    if @hand.length < 7
      @goods = []
      @folded = true
      @rank = -1
      @type = ""
    # Sweetness
    elsif royal_flush
      @rank = 200
      @type = "Royal Flush"
      sortgoods
    # Almost sweetness
    elsif straight_flush
      @rank = $values[@goods[0][0].chr] + 180
      @type = "Straight Flush (to the #{$strs[@goods[4][0].chr]})"
    # If it's some "of a kind" and it's four of a kind, then...
    elsif kind and @goods.length == 1 and @goods[0].length == 4
      @rank = $values[@goods[0][0][0].chr] + 180
      @rank += 13 if @goods[0][0][0].chr == "A"
      @type = "Four of a Kind (#{$strs[@goods[0][0][0].chr]}s)"
      sortgoods
    # I've never gotten 4 of a kind, but full house is much easier
    elsif full_house
      @rank = $values[@goods[0][0].chr] + 140
      @rank += 13 if @goods[0][0].chr == "A"
      @type = "Full House (#{$strs[@goods[0][0].chr]}s over " +
                "#{$strs[@goods[3][0].chr]}s)"
      sortgoods
    # 5 of the same suit
    elsif flush
      @rank = $values[@goods[0][0].chr] + 120
      @type = "Flush (#{$strs[@goods[0][0].chr]} high)"
      sortgoods
    # sequentially numbered, and sorted
    elsif straight
      @rank = $values[@goods[0][0].chr] + 100
      @rank += 13 if @goods[0][0].chr == "A"
      @type = "Straight (to the #{$strs[@goods[4][0].chr]})"
    # 3 of a kind
    elsif kind and @goods.length == 1 and @goods[0].length == 3
      @rank = $values[@goods[0][0][0].chr] + 80
      @rank += 13 if @goods[0][0][0].chr == "A"
      @type = "Three of a Kind (#{$strs[@goods[0][0][0].chr]}s)"
      sortgoods
    # 2 pair
    elsif kind and @goods.length == 2
      @rank = $values[@goods[1][0][0].chr] + $values[@goods[0][0][0].chr] + 40
      @rank += 13 if @goods[0][0][0].chr == "A"
      @type = "Two Pair (#{$strs[@goods[0][0][0].chr]}s and " +
                "#{$strs[@goods[1][0][0].chr]}s)"
      sortgoods
    # one pair
    elsif kind and @goods.length == 1
      @rank = $values[@goods[0][0][0].chr] + 20
      @rank += 13 if @goods[0][0][0].chr == "A"
      @type = "Pair (#{$strs[@goods[0][0][0].chr]}s)"
      sortgoods
    # high card
    else
      handdup = @hand.dup
      aces = handdup.find_all { |x| x[0].chr == "A" }
      aces.each { |ace| handdup.push("X" + ace[1].chr) }
      c = handdup.sort { |x, y| $values[x[0].chr] <=> $values[y[0].chr] }[-1]
      # Toss this kicker, if need be
      @kickers.delete($values[c[0].chr])
      @rank = $values[c[0].chr]
      c = "A" + c[1].chr if c[0].chr == "X"
      @goods = [c]
      @type = "#{$strs[c[0].chr]} High"
      # push on -1 for completeness.  I don't actually use the second value
      # but if i ever do, all kickers have 2 elements.  the second one, in
      # this case, just sucks.
      @kickers.push(-1) if @kickers.length == 1
    end
  end

  # Find out if we have a straight
  def straight
    handdup = @hand.dup
    # find all aces and push on new aces in their "high" value with the
    # same suit
    aces = handdup.find_all { |x| x[0].chr == "A" }
    aces.each { |ace| handdup.push("X" + ace[1].chr) }
    # Sort it ascending
    handdup = handdup.sort { |x, y| $values[x[0].chr] <=> $values[y[0].chr] }
    c = 1
    result = [handdup[0]]
    # iterate starting at the second card
    handdup[1..-1].each_index { |x|
      # no hope -- we've exhausted the cards at this point
      break if handdup.length - x < 5 - result.length
      # If there is a one number difference
      if $values[handdup[x + 1][0].chr] - $values[handdup[x][0].chr] == 1
        result.push(handdup[x + 1])
      elsif $values[handdup[x + 1][0].chr] - $values[handdup[x][0].chr] > 1
        # There's a gap bigger than one.  We're toast, unless we've already
        # found something
        if result.length != 5
          result = [handdup[x + 1]]
        else
          break
        end
      end
    }
    # Convert X's back into A's
    result.map! { |x|
      if x[0].chr == "X"
        "A" + x[1].chr
      else
        x
      end
    }
    # no luck here
    result = [] if result.length < 5
    # Whoopie... we found a straight
    result = result[-5..-1] if result.length > 5
    @goods = result
    return true if @goods.length != 0
    return false
  end

  # Use the results of the straight to find the straight flush.
  def straight_flush
    straight
    # This code tests to see if this is a straight flush and if it isn't it
    # swaps in the two unused cards to see if they make a straight flush.
    # We don't care about efficiency here by writing a lot of tests.  Just
    # swap the damned things in and see if it worked.
    if @goods.map { |x| x[1].chr }.uniq.length != 1
      if @goods.length != 0
        nons = @hand.select { |x| not @goods.member? x }
        goodsdup = @goods.dup
        if goodsdup.delete_if { |x| x[0].chr == nons[0][0].chr }.length == 4
          goodsdup.push(nons[0])
        end
        if goodsdup.map { |x| x[1].chr }.uniq.length != 1
          if goodsdup.delete_if { |x| x[0].chr == nons[1][0].chr }.length == 4
            goodsdup.push(nons[1])
          end
          if goodsdup.map { |x| x[1].chr }.uniq.length != 1
            if @goods.delete_if { |x| x[0].chr == nons[1][0].chr }.length == 4
              @goods.push(nons[1])
            end
            if @goods.map { |x| x[1].chr }.uniq.length != 1
              @goods = []
            end
          else
            @goods = goodsdup
          end
        else
          @goods = goodsdup
        end
      end
    end
    return true if @goods.length != 0
    return false
  end

  # find out if the straight flush is royal.
  def royal_flush
    straight_flush
    @goods = [] unless @goods.length == 5 and @goods[4][0].chr == "A"
    return true if @goods.length != 0
    return false
  end

  # find out if there is a flush... there's got to be a cooler way to do
  # this
  def flush
    @goods = @hand.select { |x| x[1].chr == "s" }
    @goods = @hand.select { |x| x[1].chr == "c" } if @goods.length == 0
    @goods = @hand.select { |x| x[1].chr == "d" } if @goods.length == 0
    @goods = @hand.select { |x| x[1].chr == "h" } if @goods.length == 0
    @goods = @goods.sort { |x, y|
      $values[x[0].chr] <=> $values[y[0].chr]
    }.reverse
    return true if @goods.length == 5
    return false
  end

  # Return all "of a kind"s
  def all_kinds
    result = []
    hash = {}
    @hand.each { |x|
      hash[x[0].chr] ||= []
      hash[x[0].chr].push(x)
    }
    hash.each_value { |v| result.push(v) if v.length > 1 }
    return [] if result.length == 0
    result = result.sort { |x, y|
      if x.length == y.length
        $values[x[0][0].chr] <=> $values[y[0][0].chr]
      else
        x.length <=> y.length
      end
    }.reverse
    return result
  end

  # return the best "of a kind"
  def kind
    result = all_kinds
    if result.length != 0
      @goods = result if result.length == 1
      @goods = [result[0]] if result[0].length > 2
      @goods = [result[0], result[1]] if result.length >= 2
    else
      @goods = []
    end
    return true if @goods.length != 0
    return false
  end

  # find out if there is 3 of a kind and 2 of a kind.  if there is then
  # this is a full house
  def full_house
    result = all_kinds
    if result.length == 2 and result[0].length == 3
      @goods = result[0] + result[1]
    else
      @goods = []
    end
    return true if @goods.length != 0
    return false
  end

  # pretty output -- ordered the way Bob wanted
  def to_s
    if @type.length != 0
      # figure out the kickers, used cards, and non-used cards
      kicks = @hand[0..1].sort { |x, y| x[0].chr <=> y[0].chr }
      used = @goods
      nons = @hand.select { |x|
        not used.member? x
      }.sort { |x, y|
        x[0].chr <=> y[0].chr
      }
      # get rid of the kickers if they're used
      kicks.delete_at(0)  if used.member? kicks[0]
      kicks.delete_at(-1) if used.member? kicks[-1]
      # get rid of the nons if they're kickers
      kicks.each { |x| nons.delete(x) }
    else
      used = kicks = []
      nons = @hand
    end
    "%-20s  #{@type}" % (used + kicks + nons).join(' ')
  end

end

# Read the stuff in -- currently only reads from a file simply because i
# wasn't able to get windows piping to work properly... i hate windows, but
# had no unix box at the time.
hands = []
while line = gets
  hands.push(Classifier.new(line.chomp.split(/ /)))
  hands[-1].classify
end

# Rank them
sorted = hands.sort { |x, y|
  if x.rank == y.rank
    x.kickers[0] <=> y.kickers[0]
  else
    x.rank <=> y.rank
  end
}.reverse

# Set any pushes to winners
sorted.select { |x|
  x.rank == sorted[0].rank and x.kickers[0] == sorted[0].kickers[0]
}.each { |x| x.winner = true }

# The holy grail
hands.each { |x|
  puts x.to_s + (x.winner ? " (winner)" : "")
}
