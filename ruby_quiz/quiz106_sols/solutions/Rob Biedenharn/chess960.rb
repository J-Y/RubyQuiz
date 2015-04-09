#!/usr/bin/env ruby -w
#
# Solution by: Rob Biedenharn
#
# From:   james@grayproductions.net
# Subject: [QUIZ] Chess960 (#106)
# Date: December 15, 2006 8:50:58 AM EST
# To:   ruby-talk@ruby-lang.org
#
# by Kieran Wild
#
# Chess960, is a chess variant produced by Grandmaster Bobby Fischer by
# formalizing the rules of Shuffle Chess. Its goal was to create a chess
# variant in which chess creativity and talent would be more important than
# memorization and analysis of opening moves. His approach was to create a
# randomized initial chess position, which would thus make memorizing chess
# opening move sequences far less helpful. The initial position is set up in a
# special way and there are 960 such positions, thus the name Chess960.
#
# The starting position for Chess960 must meet certain rules. White pawns are
# placed on the second rank as in chess. All remaining white pieces are placed
# randomly on the first rank, but with the following restrictions:
#
# 	* The king is placed somewhere between the two rooks.
# 	* The bishops are placed on opposite-colored squares.
#
# The black pieces are placed equal-and-opposite to the white pieces. For
# example, if the white king is placed on b1, then the black king is placed on
# b8. Note that the king never starts on file a or h, because there would be
# no room for a rook
#
# Can I suggest a nice little ruby program to generates all 960 possible
# starting positions and outputs a random one on request.
# ----------------------------------------------------------------------------
# From wikipedia:
# http://en.wikipedia.org/wiki/Chess960_starting_position
#
# http://en.wikipedia.org/wiki/Chess960_Enumbering_Scheme
#
# Direct Derivation
#
# The accurate sequence of White's Chess960 starting array could be derived
# from its number as follows:
#
debug=ENV['DEBUG']
puts "ARGV: #{ARGV.join(', ')}" if debug

starting_position = ARGV.empty? ? rand(960) : ARGV[0].to_i
string = '-' * 8
# a) Divide the number by 960, determine the remainder (0 ... 959) and use
# that number thereafter.
temp = starting_position % 960

puts "starting_position #{starting_position}" if debug
puts "a)   #{string}" if debug

# b) Divide the number by 4, determine the remainder (0 ... 3) and
# correspondingly place a Bishop upon the matching bright square (b, d, f, h).
temp,lb = temp.divmod 4
string[2*lb+1]='B'

puts "b) #{lb} #{string} #{temp}" if debug

# c) Divide the number by 4, determine the remainder (0 ... 3) and
# correspondingly place a Bishop upon the matching dark square (a, c, e, g).
temp,db = temp.divmod 4
string[2*db]='B'

puts "c) #{db} #{string} #{temp}" if debug

# d) Divide the number by 6, determine the remainder (0 ... 5) und
# correspondingly place the Queen upon the matching of the six free squares.
n,q = temp.divmod 6
print "d) #{q} " if debug
string.gsub!(/-/) { |p| p='Q' if q.zero?; q -= 1; p }
puts "#{string} #{n}" if debug

# e) Now only one digit (0 ... 9) is left on hand; place the both Knights upon
# the remaining five free squares according to following scheme:
#
# Digit	Knights' Positioning
# 0	N	N	-	-	-
# 1	N	-	N	-	-
# 2	N	-	-	N	-
# 3	N	-	-	-	N
# 4	-	N	N	-	-
# 5	-	N	-	N	-
# 6	-	N	-	-	N
# 7	-	-	N	N	-
# 8	-	-	N	-	N
# 9	-	-	-	N	N

require 'enumerator'
class Integer
  def comb(r=1)
    if self < r or r < 1
    elsif r == 1
      0.upto(self-1) { |x| yield [x] }
    else
      (0...self).each_cons(1) do |i|
        (self-1).comb(r-1) do |j|
          next if j.last + i.last >= self-1
          bump=i.last+1
          yield(i + j.map! { |e| e+bump })
        end
      end
    end
  end
end

print "e) #{n} " if debug
5.comb(2) do |c|
#   puts "comb: #{c.join(' ')}" if debug
  if n.zero?
    c.reverse.each do |q|
      string.gsub!(/-/) { |p| p='N' if q.zero?; q -= 1; p }
    end
    break
  end
  n -= 1
end

puts "#{string}" if debug

# f) The now still remaining three free squares will be filled in the
# following sequence: Rook, King, Rook.
puts "f)" if debug
%w[ R K R ].each do |p|
  string[string.index('-')] = p
  puts "   #{string}" if debug
end

fen = "#{string.downcase}/#{'p'*8}/8/8/8/8/#{'P'*8}/#{string} w KQkq - 0 1"

puts %{[Event "Starting Position #{starting_position}"]}
puts %{[SetUp "1"]}
puts %{[FEN "#{fen}"]}
