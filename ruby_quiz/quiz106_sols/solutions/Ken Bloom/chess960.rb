#!/usr/bin/env ruby
require 'rubygems'
require 'facets/core/enumerable/permutation'
require 'set'
i=ARGV[0] || rand(960)+1
i=i.to_i
fail "A number between 1 and 960 is required" if not (1..960).include? i
pieces=%w'K R N B B Q N R'
generated=Set.new
pieces.each_permutation do |p|
  arrangement=p.join
  if arrangement=~/R.*K.*R/ and arrangement=~/B(..)*B/ and
      not generated.include?(arrangement)

    #the "generated" set is needed because identical objects will
    #nevertheless appear in both possible permutations, like so:
    # [1,1].each_permutation {|pe| p pe}
    # gives the output
    # [1, 1]
    # [1, 1]
    generated.add arrangement

    if generated.size==i
      print "Position ##{generated.size}:", arrangement, "\n"
      break
    end
  end
end
