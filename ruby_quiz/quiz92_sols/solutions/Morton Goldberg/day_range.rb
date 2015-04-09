require 'test/unit'

class DayRange

   DAY_DIGITS = {
      'mon' => 1,
      'tue' => 2,
      'wed' => 3,
      'thu' => 4,
      'fri' => 5,
      'sat' => 6,
      'sun' => 7,
      'monday' => 1,
      'tuesday' => 2,
      'wednesday' => 3,
      'thursday' => 4,
      'friday' => 5,
      'saturday' => 6,
      'sunday' => 7,
      '1' => 1,
      '2' => 2,
      '3' => 3,
      '4' => 4,
      '5' => 5,
      '6' => 6,
      '7' => 7
   }

   SHORT_NAMES = %w[_ Mon Tue Wed Thu Fri Sat Sun].freeze

   LONG_NAMES = %w[_ Monday Tuesday Wednesday Thursday
                   Friday Saturday Sunday].freeze

   # Return day range as nicely formatted string.
   # If @long is true, day names appear in long form; otherwise, they
   # appear in short form.
   def to_s
      names = @long ? LONG_NAMES : SHORT_NAMES
      result = []
      @days.each do |d|
         case d
         when Integer
            result << names[d]
         when Range
            result << names[d.first] + "-" + names[d.last]
         end
      end
      result.join(", ")
   end

   # Return day range as array of integers.
   def to_a
      result = @days.collect do |d|
         case d
         when Integer then d
         when Range then d.to_a
         end
      end
      result.flatten
   end

   def initialize(*args)
      @days = []
      @long = false
      @args = args
      @args.each do |arg|
         case arg
         when Integer
            bad_arg if arg < 1 || arg > 7
            @days << arg
         when /^(.+)-(.+)$/
            begin
               d1 = DAY_DIGITS[$1.downcase]
               d2 = DAY_DIGITS[$2.downcase]
               bad_arg unless d1 && d2 && d1 <= d2
               d1.upto(d2) {|d| @days << d}
            rescue StandardError
               bad_arg
            end
         else
            d = DAY_DIGITS[arg.downcase]
            bad_arg unless d
            @days << d
         end
      end
      @days.uniq!
      @days.sort!
      normalize
   end

# Use this to change printing behavior from short day names to long day
# names or vice-versa.
attr_accessor :long

private

   # Convert @days from an array of digits to normal form where runs of
   # three or more consecutive digits appear as ranges.
   def normalize
      runs = []
      first = 0
      for k in 1...@days.size
         unless @days[k] == @days[k - 1].succ
            runs << [first, k - 1] if k - first > 2
            first = k
         end
      end
      runs << [first, k] if k - first > 1
      runs.reverse_each do |r|
         @days[r[0]..r[1]] = @days[r[0]]..@days[r[1]]
      end
   end

   def bad_arg
      raise(ArgumentError,
            "Can't create a DayRange from #{@args.inspect}")
   end

end

class TestDayRange < Test::Unit::TestCase

   # All these produce @days == [1..7].
   ONE_RANGE = [
      %w[mon tue wed thu fri sat sun],
      %w[monDay tuesday Wednesday Thursday friDAY saturday SUNDAY],
      %w[mon-fri sat-sun],
      %w[4-7 1-3],
      (1..7).to_a.reverse,
      [4, 7, 6, 5, 4, 1, 2, 1, 2, 3, 3, 7, 6, 5],
   ]

   # Both these produce @days == [1..3, 5..7].
   TWO_RANGES = [
      %w[mon-mon tue-tue wed-wed fri-sun],
      [1, 2, 'mon-wed', 'friday', 6, 7]
   ]

   INVALID_ARGS = [
      [1, 2, 'foo'],
      %w[foo-bar],
      %w[sat-mon],
      (0..7).to_a.reverse,
      (1..8).to_a
   ]

   @@one_range = []
   @@two_ranges = []

   def test_args_helper(args, expected)
      obj = nil
      assert_nothing_raised(ArgumentError) {obj = DayRange.new(*args)}
      assert_equal(expected, obj.instance_variable_get(:@days))
      obj
   end

   def test_valid_args
      ONE_RANGE.each do |args|
         @@one_range << test_args_helper(args, [1..7])
      end
      TWO_RANGES.each do |args|
         @@two_ranges << test_args_helper(args, [1..3, 5..7])
      end
      puts "test_valid_args -- #{@@one_range.size}, #{@@two_ranges.size}"
   end

   def test_bad_args
      puts "test_bad_args"
      INVALID_ARGS.each do |args|
         assert_raise(ArgumentError) {DayRange.new(*args)}
      end
   end

   def test_to_s
      puts "test_to_s -- #{@@one_range.size}, #{@@two_ranges.size}"
      @@one_range.each do |obj|
         assert_equal('Mon-Sun', obj.to_s)
      end
      @@two_ranges.each do |obj|
         assert_equal('Mon-Wed, Fri-Sun', obj.to_s)
      end
   end

   def test_to_a
      puts "test_to_a -- #{@@one_range.size}, #{@@two_ranges.size}"
      @@one_range.each do |obj|
         assert_equal((1..7).to_a, obj.to_a)
      end
      @@two_ranges.each do |obj|
         assert_equal([1, 2, 3, 5, 6, 7], obj.to_a)
      end
   end

end
