#! /usr/local/bin/ruby
require 'magic_square'

if ARGV.size == 1

 size = ARGV.first.to_i
end
if size && size > 0 && size != 2
 puts MagicSquare.new(size)
else
 print ["ms.rb prints a magic square of order n", "",
        "Usage:", "  ms n", "", "  where n is an integer > 0 and not = 2", ""
 ].join("\n")
end
