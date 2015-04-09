require 'narray'

class NArray;
  include Enumerable;
  srand(1)
end

class Fixnum
  NUMS = %w(zero one two three four five six seven eight nine ten eleven) +
    %w(twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen)
  TENS = %w(no teen twenty thirty forty fifty sixty seventy eighty ninety)

  def to_english
    return NUMS[self] if self < 20
    return TENS[self / 10] if (self % 10).zero?
    TENS[self / 10] + '-' + NUMS[self % 10]
  end
end

class String
  def to_na
    freq = NArray.int(26)
    each_byte do |b|
      freq[b - ?a] += 1 if b >= ?a and b <= ?z
      freq[b - ?A] += 1 if b >= ?A and b <= ?Z
    end
    freq
  end
end

text = "This is a pangram from simon, it contains "
nums = NArray[*(0..99).map{|i| i.to_english.to_na + (i>1 ? 's' : '').to_na}]
seed = text.to_na + 'and'.to_na + 1
guess = NArray.int(26).fill!(1)
real = seed + nums[true, guess].sum(1)
rnd = NArray.float(26)

while real != guess
  guess.add! rnd.random!.mul!(real.sbt!(guess)).round
  real.fill!(0).add!(seed).add!(nums[true, guess].sum(1))
end

s = guess.zip([*(' a'..' z')]).map{|g, l| g.to_english + l + (g>1 ? "'s":"")}
result = text + s[0..-2].join(', ') + ' and ' + s.last + '.'

puts result
puts(result.to_na == guess)
