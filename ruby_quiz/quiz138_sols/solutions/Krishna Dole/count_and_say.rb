# Krishna Dole's solution to Ruby Quiz 138.
# I followed Glenn Parker's reasoning on naming numbers, but didn't look at his code.

class CountSay

  def initialize(str)
    @str = str
  end

  def succ
    letters = @str.scan(/\w/)
    @str = letters.uniq.sort.map do |l|
      [letters.select{ |e| e == l }.size.to_words, l]
    end.join(" ").upcase
  end

  def each(limit = nil)
    if limit.nil?
      while true
        yield succ
      end
    else
      limit.times { yield succ }
    end
  end

end

class Integer
  NUMS_0_19 = %w(zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen)
  NUMS_TENS = [nil, nil] + %w(twenty thirty forty fifty sixty seventy eighty ninety)
  NUMS_TRIPLETS = [nil] + %w(thousand million billion trillion)

  # Return the english words representing the number,
  # so long as it is smaller than 10**15.
  # The specifications for this method follow the reasoning in:
  # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/135449
  # though I wrote the code without seeing Glenn's.
  def to_words
    case self
    when 0..19
      NUMS_0_19[self]
    when 20..99
      a, b = self.divmod(10)
      [NUMS_TENS[a], NUMS_0_19[b]].reject { |w| w == "zero" }.join("-")
    when 100..999
      a, b = self.divmod(100)
      "#{NUMS_0_19[a]} hundred#{b == 0 ? '' : ' ' + b.to_words}"
    else
      raise "Too lazy to write numbers >= 10**15" if self >= 10**15
      triplet = (self.to_s.size - 1) / 3 # find out if we are in thousands, millions, etc
      a, b = self.divmod(10**(3 * triplet))
      "#{a.to_words} #{NUMS_TRIPLETS[triplet]}#{b == 0 ? '' : ' ' + b.to_words}"
    end
  end

end

class SimpleCycleDetector

  # Expects an object that responds to #each.
  # Returns an array containing the number of
  # iterations before the cycle started, the length
  # of the cycle, and the repeated element.
  def self.detect(obj)
    results = []
    obj.each do |e|
      if i = results.index(e)
        return [i, results.size - i, e]
      else
        results << e
      end
    end
  end

end



unless ARGV[0] == "-test"

  seed = if ARGV.empty?
    "LOOK AND SAY"
  else
    ARGV.join(' ').upcase
  end

  puts "Seeding CountSay with '#{seed}'"
  cs = CountSay.new(seed)
  initial, period, phrase = SimpleCycleDetector.detect(cs)
  puts "Repeated phrase '#{phrase}.' Started cycle of length #{period} after #{initial} iterations."

else
  require "test/unit"

  class TestToWords < Test::Unit::TestCase

    def test_to_words_0_19
      assert_equal("zero", 0.to_words)
      assert_equal("nine", 9.to_words)
      assert_equal("eleven", 11.to_words)
      assert_equal("nineteen", 19.to_words)
    end

    def test_to_words_20_99
      assert_equal("twenty", 20.to_words)
      assert_equal("twenty-one", 21.to_words)
      assert_equal("forty-two", 42.to_words)
      assert_equal("seventy-seven", 77.to_words)
      assert_equal("ninety-nine", 99.to_words)
    end

    def test_to_words_100_999
      assert_equal("one hundred", 100.to_words)
      assert_equal("nine hundred three", 903.to_words)
      assert_equal("two hundred fifty-six", 256.to_words)
    end

    def test_to_words_999_and_up
      assert_equal("one thousand", 1000.to_words)
      assert_equal("one thousand one hundred one", 1101.to_words)
      assert_equal("twenty-two thousand", 22_000.to_words)
      assert_equal("one million", (10**6).to_words)
      assert_equal("twenty-two million nine hundred thousand four hundred fifty-six", 22_900_456.to_words)
      assert_equal("nine hundred ninety-nine trillion twenty-two million four thousand one", 999_000_022_004_001.to_words)
      assert_equal("nine hundred ninety-nine trillion nine hundred ninety-nine billion nine hundred ninety-nine million nine hundred ninety-nine thousand nine hundred ninety-nine",
                   999_999_999_999_999.to_words)
    end

    def test_error_on_big_number
      assert_raise(RuntimeError) { (10**15).to_words }
      assert_nothing_raised(RuntimeError) { ((10**15) - 1).to_words }
    end

  end

  class TestSimpleCyleDetector < Test::Unit::TestCase
    def setup
      @nums = [1,2,3,1,2,3]
      @letters = %w( x y a b c d a e f )
    end

    def test_detect
      assert_equal([0, 3, 1], SimpleCycleDetector.detect(@nums))
      assert_equal([2, 4, 'a'], SimpleCycleDetector.detect(@letters))
    end
  end

  class TestCountSay < Test::Unit::TestCase

    def setup
      @output = <<END_OUTPUT
0. LOOK AND SAY
1. TWO A ONE D ONE K ONE L ONE N TWO O ONE S ONE Y
2. ONE A ONE D SIX E ONE K ONE L SEVEN N NINE O ONE S TWO T TWO W ONE Y
3. ONE A ONE D TEN E TWO I ONE K ONE L TEN N NINE O THREE S THREE T
ONE V THREE W ONE X ONE Y
END_OUTPUT

      @lines = @output.to_a.map { |l| l[3..-2] } # without leading number or newline
      @cs = CountSay.new(@lines.first)
    end

    def test_succ
      @lines[1..-1].each do |line|
        assert_equal(line, @cs.succ)
      end
    end

    def test_each_with_limit
      @lines.shift
      @cs.each(3) do |str|
        assert_equal(@lines.shift, str)
      end
    end

  end
end
