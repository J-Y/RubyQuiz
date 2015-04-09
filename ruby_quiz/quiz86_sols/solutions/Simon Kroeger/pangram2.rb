require 'narray'
class NArray; include Enumerable; end
srand(1)

NUMS = %w(no one two three four five six seven eight nine ten eleven) +
  %w(twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen)
TENS = [nil] + %w(teen twenty thirty forty fifty sixty seventy eighty ninety)

class Fixnum
  def to_english
    return NUMS[self] if self < 20
    return TENS[self / 10] if (self % 10).zero?
    TENS[self / 10] + '-' + NUMS[self % 10]
  end
end

class String
  def to_na
    count = NArray.byte(26)
    each_byte do |b|
      count[b - ?a] += 1 if b >= ?a and b <= ?z
      count[b - ?A] += 1 if b >= ?A and b <= ?Z
    end
    count
  end
end

text = "This is a pangram from simon, it contains "
number = (0..99).map{|i| i.to_english.to_na + (i > 1 ? 's' : '').to_na}
guess = NArray.byte(26).fill!(1)
real = guess + text.to_na + 'and'.to_na + (number[1] * 26)

i, r, g, changed = nil, nil, nil, true
while changed do
  changed = false
  26.times do |i|
    g = guess[i]
    r = real[i]
    if g != r
      real.sbt! number[g]
      guess[i] = g = (g < r ? g : r) + rand((g - r).abs + 1)
      real.add! number[g]
      changed = true
    end
  end
end

s = guess.zip([*(' a'..' z')]).map{|g, l| g.to_english + l + (g>1 ? "'s":"")}
result = text + s[0..-2].join(', ') + ' and ' + s.last + '.'

puts result
puts(result.to_na == guess)
