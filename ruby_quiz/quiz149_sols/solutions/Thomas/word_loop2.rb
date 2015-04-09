#!/usr/bin/env ruby
# Author::      Thomas Link (micathom AT gmail com)
# Created::     2007-12-08.
#
# Nervous letters movie. If you run the script with -c, only clock-wise
# permutations will be shown.

require 'curses'

class NervousLetters
   class << self
       def solve_clockwise(word)
           @@directions = {
               :right => [ 1,  0, :right, :down],
               :left  => [-1,  0, :left,  :up],
               :up    => [ 0, -1, :right, :up],
               :down  => [ 0,  1, :left,  :down],
           }
           solve(word)
       end

       def solve_any(word)
           @@directions = {
               :right => [ 1,  0, :right, :up,   :down],
               :left  => [-1,  0, :left,  :up,   :down],
               :up    => [ 0,  1, :right, :left, :up],
               :down  => [ 0, -1, :right, :left, :down],
           }
           solve(word)
       end

       def solve(word)
           Curses.init_screen
           Curses.noecho
           Curses.curs_set(0)
           begin
               @@solutions   = []
               @@stepwise    = true
               pos0          = word.size + 1
               @@canvas_size = pos0 * 2
               NervousLetters.new([], ':', word.scan(/./),
                                  pos0, pos0, :right,
                                  false, true)
           ensure
               Curses.curs_set(1)
               Curses.close_screen
           end
           if @@solutions.empty?
               puts 'No loop.'
           else
               puts "#{@@solutions.size} solutions."
           end
       end
   end

   attr_reader :letters, :letter, :pos_x, :pos_y

   def initialize(letters, letter, word, pos_x, pos_y, direction, has_knot, at_knot)
       @letters = letters.dup << self
       @letter  = letter
       @pos_x   = pos_x
       @pos_y   = pos_y
       if word.empty?
           new_solution if has_knot
       else
           @word        = word.dup
           @next_letter = @word.shift
           @has_knot    = has_knot
           _, _, *turns = @@directions[direction]
           turns.each do |turn|
               next if at_knot and turn != direction
               dx, dy, _ = @@directions[turn]
               try_next(pos_x + dx, pos_y + dy, turn)
           end
       end
   end

   def try_next(pos_x, pos_y, direction)
       has_knot = false
       @letters.each do |nervous|
           if pos_x == nervous.pos_x and pos_y == nervous.pos_y
               if @next_letter.downcase != nervous.letter.downcase
                   return
               else
                   has_knot = true
                   break
               end
           end
       end
       NervousLetters.new(@letters, @next_letter, @word,
                          pos_x, pos_y, direction,
                          @has_knot || has_knot, has_knot)
   end

   def new_solution
       @@solutions.last.draw(self) unless @@solutions.empty?
       draw
       @@solutions << self
       if @@stepwise
           Curses.setpos(@@canvas_size + 1, 0)
           Curses.addstr('-- PRESS ANY KEY (q: quit, r: run) --')
       end
       Curses.refresh
       if @@stepwise
           ch = Curses.getch
           case ch
           when ?q
               exit
           when ?r
               @@stepwise = false
           end
       else
           # sleep 0.1
       end
   end

   def draw(eraser=nil)
       consumed = []
       @letters.each do |nervous|
           if eraser
               next if eraser.letters.include?(nervous)
               letter = ' '
           else
               letter = nervous.letter
           end
           yx = [nervous.pos_y, nervous.pos_x]
           unless consumed.include?(yx)
               Curses.setpos(*yx)
               Curses.addstr(letter)
               consumed << yx
           end
       end
   end

end


if __FILE__ == $0
   case ARGV[0]
   when '--clockwise', '-c'
       clockwise = true
       ARGV.shift
   else
       clockwise = false
   end
   for word in ARGV
       if clockwise
           NervousLetters.solve_clockwise(word)
       else
           NervousLetters.solve_any(word)
       end
   end
end
