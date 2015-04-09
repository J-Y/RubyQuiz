#!/usr/bin/env ruby

def npv(ct, i)
 sum = 0
 ct.each_with_index{ |c,t| sum += c/(1 + i.to_f)**t }
 sum
end

def irr(ct)
 l = -0.9999
 sign = npv(ct, l)
#  p sign
 r = 1.0
 while npv(ct, r)*sign > 0 do
#    p npv(ct, r)
   r *= 2
   break if r > 1000
 end
 if r > 1000
   l = -1.0001
   sign = npv(ct, l)
   r = -2.0
   while npv(ct, r)*sign > 0 do
     r *= 2
     return 0.0/0.0 if r.abs > 1000
   end
 end

 m = 0
 loop do
   m = (l + r)/2.0
   v = npv(ct, m)
#    p v
   break if v.abs < 1e-8
   if v*sign < 0
     r = m
   else
     l = m
   end
 end
 m
end

if __FILE__ == $0
 p irr([-100,+30,+35,+40,+45])
 p irr([-100,+10,+10,+10])
 p irr([+100,+10,+10,+10])
 p irr([+100,-90,-90,-90])
 p irr([+0,+10,+10,+10])
end
