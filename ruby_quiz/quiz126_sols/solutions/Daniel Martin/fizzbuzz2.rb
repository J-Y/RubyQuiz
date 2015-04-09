# A> I CAN HAS INTERVIEW?  I ARE ADVANCED PROGRAMMER.
#
# B> O HAI. U CAN HAS CALLCC?  GIMMEH FIZZBUZZ SOLUTION!

f_=b_=nil
callcc { |o|
  loop do
    o = callcc {|i|f_=i; o[:Fizz]}
    2.times{o = callcc{|i|f_=i;o[]}}
  end
}
callcc { |o,n|
  loop do
    o,n = callcc {|i|b_=i; o["#{n}Buzz"]}
    4.times{o,n = callcc{|i|b_=i;o[n]}}
  end
}
f = lambda{callcc{|i|f_[i]}}
b = lambda{|n|callcc{|i|b_[i,n]}}
1.upto(100){|i|puts b[f[]]||i}

# B> KTHX. U CAN HAS THREADS?

a = nil
f = Thread.new { loop { sleep 3; print :Fizz; a = nil } }
b = Thread.new { sleep 0.2; loop { sleep 5; print :Buzz; a = nil } }
sleep 0.5
1.upto(100) {|i| a=i; sleep 1; puts "#{a}"}

# B> LOL. UR CODE IS TEH SLOW
#
# A> I MADE U ONE WITH SEMAPHORE BUT I EATED IT.
#
# B> U CAN HAS INJECT?

a='_//_/_//_/_'.gsub('_','Fizz').split('/')
b='/_///_//_'.gsub('_','Buzz').split('/')

class Array
 def roll
   self.push(self.shift).last
 end
end

(1..101).select{|n|(n%5)*(n%3)>0}.inject(0){|r,n|
  puts "#{a.roll}#{b.roll}" while n>r+=1
  puts n if n<99
  r
}

# B> I SEE WHAT YOU DID THERE
#
# A> WHAT YOU SAY !!
#
# B> U CAN HAS INJECT, RLY? NOT ALL SIDE EFFECTZ?

(1..100).inject("x"){|p,n|
  p.sub(/^((?:(?:x[^x]*){3})*)$/,'\1Fizz').
    sub(/^((?:(?:x[^x]*){5})*)$/,'\1Buzz').
    sub(/x$/,"x#{n}") + 'x'
}.sub(/^x/,'').gsub(/x/,"\n").display

# B> KTHXBYE
#
# A> I CAN HAS PHONE CALL? PLZ?
