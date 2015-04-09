#!/usr/bin/env ruby -w

#
# Stephen Waits <steve@waits.net>
#

class AlarmKeypad

  # init a keypad, with length of security code, and the code's
  # stop digits
  def initialize(code_length = 4, stop_digits = [1,2,3])
    # remember the length of the security code
    @code_length = code_length

    # and which digits cause a code to be checked
    @stop_digits = stop_digits

    # and reset our data structures to 0
    clear
  end


  # reset keypad to initial state
  def clear
    # an array of each code and how many times it's been entered
    @codes       = Array.new(10**@code_length,0)

    # last N+1 keypad button presses
    @key_history = []

    # total number of keypad button presses
    @key_presses = 0
  end


  # press a single digit
  def press(digit)
    # add digit to key history
    @key_history.shift while @key_history.size > @code_length
    @key_history << digit
    @key_presses += 1

    # see if we just tested a code
    if @stop_digits.include?(@key_history.last) and
        @key_history.length > @code_length
      @codes[@key_history[0,@code_length].join.to_i] += 1
    end
  end

  # find out if every code had been tested
  def fully_tested?
    not @codes.include?(0)
  end

  # find out if an individual code has been tested
  # NOTE: an actual keypad obviously doesn't offer this functionality;
  #       but, it's useful and convenient (and might save duplication)
  def tested?(code)
    @codes[code] > 0
  end

  # output a summary
  def summarize
    tested          = @codes.select { |c| c > 0 }.size
    tested_multiple = @codes.select { |c| c > 1 }.size

    puts "Search space exhausted." if fully_tested?
    puts "Tested #{tested} of #{@codes.size} codes " +
      "in #{@key_presses} keystrokes."
    puts "#{tested_multiple} codes were tested more than once."
  end
end


if $0 == __FILE__
  hacked_pads = []
  for i in (1..5)
    a = AlarmKeypad.new(i, [1, 2, 3])
    ("0"*i.."9"*i).each do |c|
      next if a.tested?(c.to_i)
      c.split(//).each { |d| a.press(d.to_i) }
      a.press(rand(3) + 1)
    end
    a.summarize
  end

  for i in (1..5)
    a = AlarmKeypad.new(i, [1])
    ("0"*i.."9"*i).each do |c|
      next if a.tested?(c.to_i)
      c.split(//).each { |d| a.press(d.to_i) }
      a.press(1)
    end
    a.summarize
  end
end
