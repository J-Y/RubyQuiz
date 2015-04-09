def solve(a, b)
  t = "h#{b}"
  t = "h#{b*=2}" + t while b < a
  s = "#{a}d#{a*2}"
  a *= 2;b *= 2
  s += "a#{a+=2}" while a < b
  s += t
  loop do
    l = s.length
    s.gsub!(/(\d+)d\d+a\d+a/) { "#{$1}a#{$1.to_i + 2}d" }
    s.gsub!(/4a6a8/, '4d8')
    s.gsub!(/(\D|^)(\d+)(?:\D\d+)+\D\2(\D|$)/) {$1 + $2 + $3}
    break if s.length == l
  end
  s.scan(/\d+/).map{|i|i.to_i}
end
