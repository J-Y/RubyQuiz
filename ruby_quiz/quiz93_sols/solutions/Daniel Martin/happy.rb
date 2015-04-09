#! /usr/bin/env ruby
require 'narray'

def dodigsum(initial, base)
  tmp = initial / (base ** NArray.to_na([[0],[1],[2]]))
  # I would use mod!, but my copy of narray doesn't have mod!
  tmp = tmp % base
  tmp.mul!(tmp)
  initial.fill!(0).add!(tmp.sum(1))
end

def checkbase(base = 10)
  # As shown on the list, you're guaranteed that eventually every
  # number will be two digits or less, and once there the highest
  # you'll ever get again is...
  checklimit = 2*(base-1)*(base-1)
  check = NArray.int(checklimit + 1).indgen!
  check_initial = check.dup
  dodigsum(check,base)
  checkp = check.dup

  while true do
    if check.eq(check_initial).count_true > 2
      #lp = check.mul!(check.eq(check_initial)).mask(check.ge(2)).min
      #puts "#{base} has a loop on #{lp}"
      print (base % 100 > 0 ? "." : "x")
      break
    end
    if check.le(1).count_true > checklimit
      puts "#{base} is a happy base"
      break
    end
    check[0] = check[checkp]
  end
end

2.upto(3000) { |b|
  begin
    checkbase(b)
    GC.start if (b > 300 and b % 5 == 0)
    sleep(1) if (b % 100 == 0)
  rescue Interrupt
    puts "Checking #{b}"
    checkbase(b)
  rescue Exception => e
    puts "Bailing on #{b}"
    raise e
  end
}
