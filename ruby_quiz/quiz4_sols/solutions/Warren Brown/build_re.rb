class Regexp

  # Create a namespace for our subroutines.
  module Build

    # Return the digit at index places from the right for int.
    def self.digit(int,index)
      (int / 10 ** index) % 10
    end

    # Build the smallest RE for the digits in the given range.
    def self.digit_re(first,last)
      case (last - first)
        when 0 then first.to_s
        when 1 then "[#{first}#{last}]"
        when 9 then '\d'
        else "[#{first}-#{last}]"
      end
    end

    # Build a RE for first, varying to last at digit index.
    def self.int_re(first,last,index)
      first.to_s[0...-(index + 1)] +
          digit_re(digit(first,index),digit(last,index)) +
          '\d' * index
    end

    # Build a RE for the integers in the given range.
    def self.range_re(first,last)
      # Find first difference.
      res = []
      last_len = last.to_s.length
      first_diff = 0
      last_len.downto(0) do |first_diff|
        break if digit(first,first_diff) != digit(last,first_diff)
      end
      # Find (largest, "roundest" number in range) - 1.
      roundest = (last / 10 ** first_diff) * 10 ** first_diff - 1
      # Handle everything from first to roundest - 1.
      (0...first_diff).each do |index|
        next if index < first_diff - 1 &&
            digit(roundest,index) - digit(first,index) == 9
        res << int_re(first,roundest,index)
        first = (first / 10 ** (index + 1) + 1) * 10 ** (index + 1)
        break if first > roundest
      end
      # Handle everything from roundest to last, except last digit.
      (first_diff - 1).downto(1) do |index|
        next if digit(last,index) == 0
        tmp_last = (last / 10 ** index) * 10 ** index - 1
        res << int_re(first,tmp_last,index)
        first = tmp_last + 1
      end
      # Last digit is special.
      res << int_re(first,last,0)
      res.join('|')
    end

  end

  # Build a RE for each argument.
  def Regexp.build(*args)
    res = []
    args.each do |arg|
      # If it is an integer, just match it.
      if arg.respond_to?(:to_i)
        res << arg.to_i
      # If it is a range, build the RE.
      elsif arg.respond_to?(:exclude_end?)
        last = arg.exclude_end? ? arg.last - 1 : arg.last
        res << Build::range_re(arg.first,last)
      # Otherwise, error
      else
        $stderr.puts "Unknown argument (#{arg.inspect})."
      end
    end
    # Combine REs.
    Regexp.new("\\A(#{res.join(')|(')})\\z")
  end
end


# Run some test cases.
#p Regexp.build(1..1000000)
#p Regexp.build(12345...24680)
#p Regexp.build(123..123)
#p Regexp.build(10..19)
#p Regexp.build(1..102)
#p Regexp.build(100..234)
#p Regexp.build(1990..2010)
#p Regexp.build(1..10,20,30..40,50,60,70..80)
