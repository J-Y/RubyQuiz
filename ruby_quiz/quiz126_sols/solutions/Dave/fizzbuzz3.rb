# How about something for thedailywtf.com?

def divisible_by_3(i)
  if i.to_s.size>1 then
    divisible_by_3(i.to_s.split(//).map{|char| char.to_i}.inject{|a,b| a+b})
  else
    [3,6,9].include?(i)
  end
end

def divisible_by_5(i)
  ['0','5'].include?(i.to_s[-1].chr)
end

def divisible_by_15(i)
  divisible_by_3(i) && divisible_by_5(i)
end


1..100.each do |i|
   if divisible_by_15(i) then puts 'FizzBuzz'
   elsif divisible_by_3(i) then puts 'Fizz'
   elsif divisible_by_5(i) then puts 'Buzz'
   else puts i
   end
end
