# use_magic_square.rb
require 'magic_square'

# getting input
n = ARGV[0].to_i

# input must be odd and bigger than 2
raise 'Argument must be odd and bigger than 2' if n % 2 == 0 or n < 3

odd_magic_square = OddMagicSquare.new(n)
odd_magic_square.iterate_square
odd_magic_square.printing_magic_square
