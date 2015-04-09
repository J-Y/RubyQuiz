#!/usr/bin/env ruby
require 'narray'

def dodigsum(initial, base)
  ndigits = (Math.log(initial.max)/Math.log(base)).ceil
  tmp = initial / (base ** NArray.to_na((0...ndigits).map{|x|[x]}))
  tmp = tmp % base
  tmp.mul!(tmp)
  initial.fill!(0).add!(tmp.sum(1))
end

limit  = ARGV[0] || 1_000_000
base = ARGV[1] || 10

limit = limit.to_i
base = base.to_i

check = NArray.int(limit + 1).indgen!
check_initial = check.dup
check_initial[1] = 0
dodigsum(check, base)
checkp = check.dup

onemask = check.eq(1)
# onemask now contains the location of "0 order" happy numbers
order = 0
found_ex = nil
while (check.ge(2).count_true > 0) do
  check.mul!(check.ne(check_initial))
  check = check[checkp]
  newmask = check.eq(1)
  order = order + 1
  if (not newmask == onemask)
    found_ex = [newmask.gt(onemask).where.min, order]
  end
  onemask = newmask
end
puts "Happiest is #{found_ex[0]}, with happiness order #{found_ex[1]}"
