#!/usr/bin/env ruby -w

require 'alarm_keypad'
require 'benchmark'

def crack_code (code_length, stop_digits)

  # This is the weak part of the algorithm (in the case of there being more than 1 stop digit)
  # Unfortunately, I don't have the time right now to write something better than a random
  # selection.
  stop_digit = lambda { stop_digits[rand(stop_digits.size)].to_s }

  pad = AlarmKeypad.new code_length, stop_digits

  # Work with codes with lots of stop digits in them first.
  all_codes = ("0"*code_length.."9"*code_length).to_a.sort_by{|c| num_of_stop_digs c, stop_digits }.reverse

  # This algorithm works backwards, so we start with a stop digit, followed by a code.
  # You may notice that this doesn't reverse the codes themselves, which means that
  # the code that will actually get input into the pad is the reverse of the code used.
  solution = stop_digits[0].to_s + all_codes.shift

  while !all_codes.empty?
    match = /[#{stop_digits.join}](.{0,#{code_length-1}})$/.match(solution[-code_length..-1])
    string = (match ? match[1] : nil)
    if match.nil?
      solution << stop_digit.call + all_codes.shift
    elsif string.nil? || string.empty?
      solution << all_codes.shift
    else
      overlap = match ? string.size : 0
      code = all_codes.find { |c| c.index(string) == 0 }
      if code.nil?
        code = all_codes.shift
        solution << stop_digit.call + code
      else
        all_codes.delete code
        solution << code[overlap..-1]
      end
    end
  end

  solution.reverse.split(//).each{ |d| pad.press d.to_i }
  pad
end

def num_of_stop_digs (code, stop_digits)
  stop_digits.inject(0) { |num_stop_digs, dig| num_stop_digs + code.count(dig.to_s) }
end

if __FILE__ == $PROGRAM_NAME
  include Benchmark

  bm(10) do |x|
    hacked_pad = nil
    puts "One stop digit:\n"
    puts
    for i in (2..5)
      x.report("#{i} digits") { hacked_pad = crack_code(i, [1]) }
      hacked_pad.summarize
      puts "="*60
    end

    puts
    puts "Three stop digits:"
    puts
    for i in (2..5)
      x.report("#{i} digits") { hacked_pad = crack_code(i, [1,2,3]) }
      hacked_pad.summarize
      puts "="*60
    end
  end
end
