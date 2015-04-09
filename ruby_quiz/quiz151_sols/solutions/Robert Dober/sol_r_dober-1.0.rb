#!/usr/bin/ruby
# vim: sw=2 ts=2 ft=ruby expandtab tw=0 nu syn:
#
require 'mathn'
require "enumerator"

class String
  def each_char &blk
    return enum_for(:each_byte).map{ |b| b.chr } unless blk
    enum_for(:each_byte).each do |b| blk.call b.chr end
  end 
end

class Object
  def tap
    yield self
    self
  end

  def ivars_set ivar_hash
    ivar_hash.each do | ivar_name, ivar_value |
      instance_variable_set "@#{ivar_name}", ivar_value
    end
    self
  end
end

module Probability
  def to_p digits
    "%#{digits+3}.#{digits}f%%" % ( 100 * to_f )
  end
end
[ Fixnum, Rational ].each do | number_class |
  number_class.send :include, Probability
end

NATURAL = 5
BUST    = 6
BANK_STANDS = 17
BLACKJACK   = 21

DataError = Class::new RuntimeError
Cards = %w{ 2 3 4 5 6 7 8 9 h a }

class String
  def ace 
    downcase == "a" ? 1 : 0
  end

  def value
    case self
    when "A", "a"
      11
    when "H", "h"
      10
    when "2".."9"
      to_i
    else
      nil
    end
  end
end

class Fixnum
  def add_value face_or_value
    face_or_value = face_or_value.value if String === face_or_value
    self + face_or_value
  end
end

# unmutable objects representing cards that still can be drawn
class Pack

  def initialize *args
    @data = Hash[ *args ] # a count of faces as a hash
    @total = @data.inject(0){ |sum, (k,v)| sum + v } # total count of cards
  end

  def each_with_p
    @data.each do |face, count|
      next if count.zero?
      yield face, probability( face )
    end
  end

  def probability face
    Rational @data[face], @total
  end

  def - face
    data, total = @data, @total
    self.class.allocate.instance_eval { | new_pack |
      @data = data.dup
      @data[ face ] -= 1
      raise DataError, "Cannot remove #{face}" if @data[ face ] < 0
      @total = total - 1
      new_pack
    }
  end
end # class Pack

# represents the hand of the dealer, immutable
class Hand
  attr_reader :probability
  def initialize pack, card
    @pack = pack
    @cards = [ card ]
    @count = card.value
    @aces = card.ace
    @probability = 1
  end

  def adjust_prob p
    @probability *= p
  end

  def result
    return BUST if @count > BLACKJACK
    return NATURAL if @count == BLACKJACK && @cards.size == 2
    return nil if @count < BANK_STANDS
    @count - BANK_STANDS
  end

  def + face
    count = @count + face.value
    aces = @aces + face.ace
    loop do
      break if count <= BLACKJACK || aces.zero?
      count -= 10
      aces -= 1
    end
    self.class.allocate.tap{ | new_hand |
      new_hand.ivars_set :cards => ( @cards.dup << face ), :count => count,
                         :aces => aces, :pack => @pack - face, :probability => @probability
    }
  end

  # the workerbee, recursive traversal of the game tree of the
  # dealers hand.
  def compute results
    @pack.each_with_p do | face, p |
      new_hand = self + face
      new_hand.adjust_prob p
      r = new_hand.result
      if r then
        results[ r ] += new_hand.probability
      else
        new_hand.compute results
      end
    end
  end

end


def output card, results
  puts "  #{card.upcase}  #{results.map{ |r| r.to_p(4) }.join("   ")}"
end

def usage
  puts %<usage:
  ruby #{$0} <number of decks> [visible cards]
  visible cards: One or more strings with single characters indicating
       face values as follows, 23456789[hH][aA]
  >
  exit -1
end
usage if ARGV.empty? || /^-h|^--help/ === ARGV.first

number_of_decks = ARGV.shift.to_i
visible_cards = ARGV.join.each_char.to_a
pack = Pack.new( 
      *Cards.map{ |c| [c.downcase, 
        ( c.downcase == "h" ? 4 : 1 ) * 4 * number_of_decks ]
     }.flatten )
visible_cards.each do |vc|
 pack = pack - vc.downcase
end

puts "Card    17         18         19         20         21       NATURAL     BUST"
Cards.each do
  | card |
  begin
    hand = Hand.new pack - card, card
    results = Array.new( 7 ){ 0 }
    hand.compute results
    output  card, results
  rescue DataError
    puts "  #{card.upcase}  is not left in deck"
  end
end
