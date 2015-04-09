=begin

import Data.List
import Data.Maybe

pieces = "RNBKQBNR"

permutation [] = [[]]
permutation xs = [x:y | x <- nub xs, y <- permutation $ delete x xs]

restriction position =
  r1 < k && k < r2 &&
  sum (elemIndices 'B' position) `mod` 2 /= 0
  where
  r1:r2:_ = elemIndices 'R' position
  k       = fromJust $ elemIndex 'K' position

results = filter restriction (permutation pieces)

=end

def permutation(pieces)
 return [pieces] if pieces.length <= 1
 result = []
 pieces.uniq.each do |p|
   _pieces = pieces.dup
   _pieces.delete_at(pieces.index(p))
   permutation(_pieces).each do |perm|
     result << (perm << p)
   end
 end
 result
end

results = permutation("RNBKQBNR".split(//)).select do |position|
 r1 = position.index('R')
 r2 = position.rindex('R')
 b1 = position.index('B')
 b2 = position.rindex('B')
 k = position.index('K')
 r1 < k && k < r2 && ((b1+b2) % 2 != 0)
end

puts "Total positions = #{results.length}"
puts results[rand(results.length)].join(' ')
