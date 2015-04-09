#!/usr/bin/ruby
$factCache = [ 1 ]
def factorial(n)
       return $factCache[n] if n <= $factCache.length
       prod = $factCache.last
       while $factCache.length <= n
               $factCache.push(prod *= $factCache.length)
       end
       return prod
end

def pascalCombination(n, k)
       return factorial(n) / (factorial(k) * factorial(n - k))
end

max = $*[0].to_i - 1
maxDigits = Math.log10(pascalCombination(max, max/2)).floor + 1
spaces = (maxDigits + maxDigits/2).ceil
for row in 0..max
       print " " * ((max - row)*spaces/2)
       for col in 0..row
               combination = pascalCombination(row, col)
               digitSpace = Math.log10(combination).floor + 1
               digitSpace = 1 if digitSpace == 0
               print " " * (spaces - digitSpace) + combination.to_s
       end
       print "\n"
end
