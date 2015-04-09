# Expect a block that takes a first argument of 'count' or 'reorder' depending on what
# we need to do with the current string.
# In hindsight, this could have taken two Proc objects instead: count_proc
and reorder_proc
def find_cycle string
  puts "Finding a cycle for #{string}"
  sequence = {}
  until sequence[string]
    sequence[string] = sequence.length
    string.gsub!(/ /,'')  # we ignore all spaces
    #STDOUT.write "#{string.length}:#{string[0..50]} "  #progress feedback
    string = yield( 'reorder', string )
    previous_char, count = string[0..0], 1
    counts = string.split('')[1..-1].inject([]) do |memo,obj|
      if previous_char == obj
        count += 1
      else
        memo << [yield('count',count),previous_char]
        previous_char, count = obj, 1
      end
      memo
    end
    counts << [yield('count',count),string[-1..-1]]
    string = counts.flatten.join(' ')
  end
  "Cycle found at position #{sequence.length}, duplicating position #{sequence[string]}: #{string}"
end

def count_and_say string = "1"
  find_cycle string do |operation, value|
    # in the numerical mode, each operation is a null operation
    case operation
    when 'reorder'
      value  # no need to re-order the string
    when 'count'
      value.to_s  # just make sure it is a string
    end
  end
end

def look_and_say string = "LOOK AND SAY"
  find_cycle string do |operation, value|
    case operation
    when 'reorder'
      value.split('').sort.join
    when 'count'
      value.to_i.say
    end
  end
end

class Fixnum
  NUMBERS = %w[zero one two three four five six seven eight nine ten
          eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty]
  TENS = %w[zero ten twenty thirty forty fifty sixty seventy eighty ninety]
  BIG_DIGITS = %w[zero ten hundred thousand]
  def ones_digit; (self % 10); end
  def tens_digit; ((self / 10) % 10); end
  def say
    result = []
    if NUMBERS[self % 100]
      result << NUMBERS[self % 100] if self == 0 or (self % 100) != 0
    else
      result << NUMBERS[self.ones_digit] if self.ones_digit > 0
      result << TENS[self.tens_digit]
    end
    str = self.to_s
    str[0..-3].reverse.split('').each_with_index do |char,idx|
      result << BIG_DIGITS[idx+2]
      result << NUMBERS[char.to_i] if char.to_i > 0
    end
    result.reverse.collect {|i| i.upcase }.join(' ')
  end
end
