1.upto(?d) do |x|
  p 'fizzBuzz'  if x % 15  == 0
  p 'fizz'  if x % 3 == 0
  p 'buzz'  if x % 5 == 0
  p x if x % 3 != 0
end
