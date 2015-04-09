require 'test/unit'

# Convert a number [0..999] to how it should be written in English.
class NumberToEnglish
  def initialize
     @ones = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine']
     @tens_10_to_19 = ['ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen']
     @tens_20_to_99 = ['twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety']
     @hundered = 'hundered'
  end

  def english_0_to_9 number
     return @ones[number]
  end

  def english_10_to_19 number
     return @tens_10_to_19[number - 10]
  end

  def english_0_to_19 number
     return english_0_to_9(number) if number < 10
     english_10_to_19 number
  end

  def english_20_to_99 number
     ones_part = number % 10
     tens_part = number / 10 - 2
     head = @tens_20_to_99[tens_part]
     return head if ones_part == 0
     head + '-' + english_0_to_9(ones_part)
  end

  def english_0_to_99 number
     return english_0_to_19(number) if number < 20
     english_20_to_99 number
  end

  def english_100_to_999 number
     hundereds_part = number / 100
     rest_part = number % 100
     head = @ones[hundereds_part] + ' ' + @hundered
     return head if rest_part == 0
     head + ' and ' + english_0_to_99(number % 100)
  end

  def english_0_to_999 number
     return english_0_to_99(number) if number < 100
     english_100_to_999 number
  end

  def english number
     english_0_to_999(number)
  end
end

class NumberToEnglishTest < Test::Unit::TestCase
  def setup
     @numberToEnglish = NumberToEnglish.new
  end

  def test_1
     assert_equal('zero', @numberToEnglish.english(0))
     assert_equal('one', @numberToEnglish.english(1))
     assert_equal('nine', @numberToEnglish.english(9))
     assert_equal('ten', @numberToEnglish.english(10))
     assert_equal('seventeen', @numberToEnglish.english(17))
     assert_equal('twenty', @numberToEnglish.english(20))
     assert_equal('fifty-seven', @numberToEnglish.english(57))
     assert_equal('ninety-nine', @numberToEnglish.english(99))
     assert_equal('one hundered', @numberToEnglish.english(100))
     assert_equal('one hundered and ninety-four', @numberToEnglish.english(194))
     assert_equal('two hundered', @numberToEnglish.english(200))
     assert_equal('two hundered and one', @numberToEnglish.english(201))
     assert_equal('three hundered and ninety-two', @numberToEnglish.english(392))
     assert_equal('five hundered and twenty-three', @numberToEnglish.english(523))
     assert_equal('seven hundered and seventy-seven', @numberToEnglish.english(777))
     assert_equal('eight hundered and forty-four', @numberToEnglish.english(844))
     assert_equal('nine hundered and forty-three', @numberToEnglish.english(943))
  end
end

# My (hopefully right) solution of Ruby Quiz 138.
class RQ138
  def initialize
     @numberToEnglish = NumberToEnglish.new
  end

  def say_it counts
     str = ''
     counts.sort.each do |k, v|
        str += @numberToEnglish.english(v) + ' ' + k + ' '
     end
     str.chomp
  end

  def unwind str
     only_letters = str.gsub /[^a-z]/, ''
     sorted_str = only_letters.split('').sort
     counts = {}
     sorted_str.each do |char|
        if counts[char] == nil
          counts[char] = 1
        else
          counts[char] += 1
        end
     end
     say_it counts
  end

  def find_seq str
     seq = [str]
     1.upto 10000 do
        unwound = unwind seq[seq.length - 1]
        index = seq.index(unwound)
        seq << unwound
        return [seq.length + 1, seq.length - index, seq] if index != nil
     end
     nil # Give up...
  end
end

class RQ138Test < Test::Unit::TestCase
  def setup
     @rq138 = RQ138.new
  end

  def test_1
     # WARNING: These are not real tests, since I didn't validate the results.
     assert_equal [609, 430], @rq138.find_seq('LOOK AND SAY'.downcase)[0..1]
     assert_equal [404, 67], @rq138.find_seq('A'.downcase)[0..1] # No letter A in numbers 0 - 9.
     assert_equal [404, 67], @rq138.find_seq('B'.downcase)[0..1]
     assert_equal [519, 317], @rq138.find_seq('E'.downcase)[0..1]
     assert_equal [152, 76], @rq138.find_seq('ROMANCE'.downcase)[0..1] # Romance is very short,
     assert_equal [482, 317], @rq138.find_seq('LOVE'.downcase)[0..1] # proof that love can last extremely long,
     assert_equal [92, 46], @rq138.find_seq('LINUX'.downcase)[0..1]  # Linux is very fast,
     assert_equal [783, 95], @rq138.find_seq('RUBY'.downcase)[0..1] # while Ruby stands very high.
     assert_equal [693, 160], @rq138.find_seq('izi_ttm')[0..1]  # Don't know what I should say about myself,
     assert_equal [266, 160], @rq138.find_seq('Nikola Tesla'.downcase)[0..1]  # but I sure have at least something in common with Nikola Tesla. :)
  end
end
