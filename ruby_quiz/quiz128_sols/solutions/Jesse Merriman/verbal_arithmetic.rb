#!/usr/bin/env ruby
# Ruby Quiz 128: Verbal Arithmetic
# verbal_arithmetic.rb

require 'perms_and_combs.rb'
require 'set'

class VerbalArithmetic
  # Create a new VerbalArithmetic.
  # - words:  an array of words
  # - op:     a string representation of an operation ('+', '-', or '*')
  # - result: desired result
  # - base:   numeric base
  def initialize words, op, result, base = 10
    @words, @op, @result, @base = words, Ops[op], result, base
    @first_letters = Set[ *(words.map { |w| w[0..0] } + [result[0..0]]) ]
    @max_level = (words + [result]).max { |x,y| x.length <=> y.length}.length
    self
  end

  # Returns a hash of letter => number.
  def decode level = 1, partial_mapping = {}
    words_chunk, result_chunk = right_chunk level

    each_valid_mapping(words_chunk, result_chunk, partial_mapping) do |mapping|
      if level == @max_level
        if operate_on_words(words_chunk, mapping) ==
           translate(@result, mapping) and
           not @first_letters.map{ |c| mapping[c]}.include?(0)
          return mapping
        end
      else
        d = decode(level + 1, mapping)
        return d if not d.nil?
      end
    end
  end

  private

  Ops = { '+' => lambda { |x,y| x+y },
          '-' => lambda { |x,y| x-y },
          '*' => lambda { |x,y| x*y } }

  # Yield each valid mapping.
  def each_valid_mapping words, result, partial_mapping = {}
    level = words.first.size

    each_mapping(words + [result], partial_mapping) do |mapping|
      if adjust(operate_on_words(words, mapping), level) ==
         adjust(translate(result, mapping), level)
        yield mapping
      end
    end
  end

  def operate_on_words words, mapping
    nums = []
    words.each { |word| nums << translate(word, mapping) }
    operate nums
  end

  # Operate on the given numbers.
  def operate nums
    nums.inject { |memo, n| @op[memo, n] }
  end

  # Convert a word to a number using the given mapping of letters => numbers.
  def translate word, mapping
    t = word.split(//).map { |c| mapping[c] }
    t.map { |n| n.nil? ? 0 : n }.join.to_i(@base)
  end

  # Generate possible ways of mapping the letters in words to numbers.
  # - words: an array of words
  # - determined: a previously-determined partial mapping which is to be filled
  #               out the rest of the way
  def each_mapping words, determined = {}
    letters = Set[]
    words.each do |word|
      word.each_byte { |b| letters << b.chr if not determined.has_key?(b.chr) }
    end

    # Find all arrangements of letters.size undetermined numbers and for each
    # match them up with letters.
    pool = (0...@base).to_a - determined.values
    if pool.size.zero? or letters.size.zero?
      yield determined.clone
    else
      pool.each_combination(letters.size) do |comb|
        comb.each_permutation do |perm|
          mapping = determined.clone
          letters.each_with_index { |let, i| mapping[let] = perm[i] }
          yield mapping
        end
      end
    end
  end

  # Return the result of cutting off the left-side of each word in @words and
  # @result, leaving level-length right-side strings. '0' is prepended to
  # too-short strings.
  def right_chunk level
    words_chunk = @words.map { |word| chunk(word, level) }
    res_chunk = chunk(@result, level)
    [words_chunk, res_chunk]
  end

  def chunk word, level
    word.length < level ? word : word[(word.length - level)...word.length]
  end

  # Adjust the intermediate number num. If its positive, return num modulus
  # @base ** level. Else, return the first digit of the number mod @base
  # appended to the rest of the number.
  def adjust num, level
    if num >= 0
      num % (@base ** level)
    else
      s = num.to_s
      s[0..1] = (s[0..1].to_i(@base) % @base).to_s
      s.to_i @base
    end
  end
end

# Usage:
#   verbal_arithmetic.rb WORDS OP RESULT [BASE]
#
# WORDS:  a list of words
# OP:     the operation (either +, -, or *)
# RESULT: the result of applying OP to all WORDS
# BASE:   the number base to use (default: 10)
#
# Examples:
#   verbal_arithmetic.rb 'send more' + money
#   verbal_arithmetic.rb 'forty ten ten' + sixty
if __FILE__ == $0
  words, op, result = ARGV[0].split(' '), ARGV[1], ARGV[2]
  base = (ARGV[3].nil? ? 10 : ARGV[3].to_i)

  if op == '-' and words.size != 2
    $stderr.puts 'Subtraction of anything but 2 words is not supported.'
    exit 1
  elsif ['+', '*', '-'].include? op
    va = VerbalArithmetic.new words, op, result, base
    mapping = va.decode
    if mapping
      puts 'Found mapping:'
      mapping.each { |c,n| puts "  #{c}: #{n}" }
    else
      puts 'No mapping could be found.'
    end
  else
    $stderr.puts "#{op} is not a supported operation."
    exit 1
  end
end
