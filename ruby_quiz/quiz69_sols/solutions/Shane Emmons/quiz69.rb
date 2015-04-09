# Author: Shane Emmons
#
# Quiz 69: The Golden Fibonacci Ratio.
#
# I decided for this quiz to try and use the curses library to make
# screen placement easier. I think it turned out well, though I am sure
# there are more clever ways of achieving the same results. Press the
# 'enter' key to advance through each successive iteration of the
# algorithm. Five is the optimal number of times to iterate for standard
# consoles.
#
# usage: ruby quiz69.rb [optional: number of times to add sqr]

require 'curses'

class Square

    attr_reader :height, :width
    attr_writer :height, :width

    def initialize( screen, length = 1, width = 1 )
        @screen, @height, @width = screen, length, width
    end

    def max_side
        @height >= @width ? @height : @width
    end

    def add_to_screen
        @screen.setpos( 0, 0 )
        ( 0 .. @width + 1 ).each { @screen.addstr( '#' ) }
        ( 1 .. @height ).each do |height|
            @screen.setpos( height, 0 )
            @screen.addstr( '#' )
            @screen.setpos( height, @width + 1 )
            @screen.addstr( '#' )
        end
        @screen.setpos( @height + 1, 0 )
        ( 0 .. @width + 1 ).each { @screen.addstr( '#' ) }
        @screen.getch
    end

end

add_to = :right
sqr = Square.new( Curses::init_screen )
sqr.add_to_screen

times = ARGV[ 0 ] || 5
( 1 .. times.to_i ).each do |x|

    if add_to == :right
        sqr.width  += sqr.max_side + 1
    else
        sqr.height += sqr.max_side + 1
    end

    add_to = add_to == :right ? :bottom : :right
    sqr.add_to_screen

end
