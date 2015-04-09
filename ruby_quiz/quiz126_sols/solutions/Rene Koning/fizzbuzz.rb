class Fixnum
 def dividable_by?(num)
  self % num == 0
 end
end

(1..100).each do |num| 
 puts case true
  when num.dividable_by?(3*5): "fizzbuzz"
  when num.dividable_by?(5): "buzz"
  when num.dividable_by?(3): "fizz"
  else num.to_s
 end
end