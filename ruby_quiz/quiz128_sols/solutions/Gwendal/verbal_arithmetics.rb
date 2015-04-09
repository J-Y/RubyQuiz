#!/usr/local/bin/ruby
# lagroue@free.fr

class Array
  # Yields all permutations of elements of self.
  # Provide with max_length in order to limit permutations length
  #
  # perms=[]; [0,1,2].permutations { |perm| perms << perm }; perms
  # => [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
  # perms=[]; [0,1,2,3].permutations(2) { |perm| perms << perm }; perms
  # => [[0, 1], [0, 2], [0, 3], [1, 0], [1, 2], [1, 3], [2, 0], [2, 1], [2, 3], [3, 0], [3, 1], [3, 2]]
  
  def permutations(max_length=nil)
    if empty? || max_length == 0
      yield []
    else
      max_length -= 1 if max_length
      (0...length).each { |index| (self[0...index]+self[(index+1)..-1]).permutations(max_length) { |perm| yield [self[index]]+perm } }
    end
  end
end

# Given a sentence, like 'forty+ten+ten=sixty', return a translation Array, or nil if none could be found.
#
# verbal_arithmetics('forty+ten+ten=sixty')
# => [["f", 2], ["t", 8], ["s", 3], ["o", 9], ["r", 7], ["y", 6], ["e", 5], ["n", 0], ["i", 1], ["x", 4]]
def verbal_arithmetics(sentence)
  digits = []           # all digits actually used in sentence.
  primary_digits = []   # the digits which should not translate to zero.
  sentence.scan(/\b(\w+)\b/).each { |number|
    number_digits = number.first.split('')
    primary_digits |= [number_digits.first]
    digits |= number_digits
  }
  raise "Too many digits" if digits.length > 10
  
  # reorder digits : primary first, then secondary
  secondary_digits = digits - primary_digits
  digits = primary_digits + secondary_digits
  
  # rewrite sentence : "hello" => 10*(10*(10*(10*(h)+e)+l)+l)+o
  sentence = sentence.gsub(/\b(\w+)\b/) { '('+$1.split('').inject('') { |s,d| if s.empty? then d else "10*(#{s})+#{d}" end } + ')'}.gsub('=', '==')
    
  # test all permutations of actual digits
  (0..9).to_a.permutations(digits.length) { |permutation|
    next if permutation[0...(primary_digits.length)].include?(0) # reject 0 for primary digits
    translation = digits.zip(permutation)
    # evalute "a=1;b=2;c=3;...;sentence"
    return translation if eval((translation.map { |(digit, number)| "#{digit}=#{number}" } << "#{sentence}").join(';'))
  }
  
  # no solution
  nil
end

if ARGV.empty?
  puts "exemple: verbal_arithmetics 'send+more=money'"
else
  sentence = ARGV[0].dup
  translation = verbal_arithmetics(sentence)
  if translation
    translation.each { |(digit, number)|
      sentence.gsub!(digit, number.to_s)
      puts "#{digit}: #{number}"
    }
    puts sentence
  else
    puts "no solution"
  end
end
