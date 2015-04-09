class Integer
  GROUPS =%W{ THOUSAND MILLION BILLION TRILLION QUADRILLION QUINTILLION SEXILLION SEPTILLION OCTILLION NONILLION}.unshift nil
  DIGITS = %W{ONE TWO THREE FOUR FIVE SIX SEVEN EIGHT NINE}.unshift nil
  TEENS = %W{TEN ELEVEN TWELVE THIRTEEN FOURTEEN FIFTEEN SIXTEEN SEVENTEEN EIGHTEEN NINETEEN}
  TENS = %W{TEN TWENTY THIRTY FOURTY FIFTY SIXTY SEVENTY EIGHTY NINETY}.unshift nil
  def to_w
    return @word if @word
    p "making word for #{self}" if $DEBUG
    digits = to_s.split('').reverse.map{|c|c.to_i}
    return @word = "DECILLIONS" if digits.size > 33
    phrase,group = [],0
    until digits.empty?
      phrase << GROUPS[group]
      d = digits.slice!(0,3)
      d[1]||=0
      if d[1] == 1
        phrase << TEENS[d[0]]
      else
        phrase << DIGITS[d[0]] << TENS[d[1]]
      end
      phrase << "HUNDRED" << DIGITS[d[2]]  if (d[2] and d[2]!=0)
      phrase.pop if (phrase.compact! and phrase[-1] ==  GROUPS[group])
      group+=1
    end
    @word = phrase.reverse.join ' '
  end
end


if __FILE__ == $0

phrase = ARGV[0]||"LOOK AND SAY"
print = ARGV[1] == 'p'
results=[];
h=Hash.new(0)
i=0
str = phrase.upcase
puts str
until (m = results.index str)
  print "#{i}: ", str, "\n" if print
  results<< str
  str.split('').each{|c| h[c]+=1}
  h.delete(' ')
  str = h.to_a.sort.map{|c,n| [n.to_w,c] }.join " "
  h.clear
  i+=1
end
puts "\nAfter #{i} iterations, repeated pattern #{m}: "
puts str
puts "Loop length = #{i-m}"
end
