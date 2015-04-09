#! /usr/bin/env ruby -w
#
# Ruby Quiz 106 -- Chess960 Starting Positions
# Implementation uses Scharnagl's tables. See
#     http://en.wikipedia.org/wiki/Chess960_starting_position

class Chess960
   BISHOP_TABLE = [
      "BB------", #0
      "B--B----", #1
      "B----B--", #2
      "B------B", #3
      "-BB-----", #4
      "--BB----", #5
      "--B--B--", #6
      "--B----B", #7
      "-B--B---", #8
      "---BB---", #9
      "----BB--", #10
      "----B--B", #11
      "-B----B-", #12
      "---B--B-", #13
      "-----BB-", #14
      "------BB"  #15
   ]

   N5N_TABLE = [
      "NN---", #0
      "N-N--", #1
      "N--N-", #2
      "N---N", #3
      "-NN--", #4
      "-N-N-", #5
      "-N--N", #6
      "--NN-", #7
      "--N-N", #8
      "---NN"  #9
   ]

   def initialize(number)
      q, @bishop_index = (number - 1).divmod 16
      @knight_index, @queen_index = q.divmod 6
      @white_pieces = BISHOP_TABLE[@bishop_index].split('')
      @white_pieces[nth_dash(@queen_index)] = 'Q'
      knights = N5N_TABLE[@knight_index]
      m = knights.index('N')
      n = knights.index('N', m + 1)
      m, n = nth_dash(m), nth_dash(n)
      @white_pieces[m] = 'N'
      @white_pieces[n] = 'N'
      @white_pieces[@white_pieces.index('-')] = 'R'
      @white_pieces[@white_pieces.index('-')] = 'K'
      @white_pieces[@white_pieces.index('-')] = 'R'
   end

   def nth_dash(n)
      dashes = []
      @white_pieces.each_with_index { |ch, i| dashes << i if ch == '-' }
      dashes[n]
   end

   def inspect
      @white_pieces.join
   end

   def to_s
      white_pieces = @white_pieces.join + "\n"
      white_pawns = 'P' * 8 + "\n"
      black_pieces = white_pieces.downcase
      black_pawns = 'p' * 8 + "\n"
      empty = ('.' * 8 + "\n") * 4
      black_pieces + black_pawns + empty + white_pawns + white_pieces
   end
end

if __FILE__ == $0
   begin
      if ARGV.empty? then n = 1 + rand(960)
      else
         n = ARGV.first.to_i
         raise StandardError unless (1..960).include?(n)
      end
      puts "Initial position #{n}"
      print Chess960.new(n).to_s
   rescue StandardError
      puts "Usage:  #{$PROGRAM_NAME} [<integer>]"
      puts "where <integer> is in 1..960"
      puts "Omitting <integer> produces a random initial position"
   end
end
