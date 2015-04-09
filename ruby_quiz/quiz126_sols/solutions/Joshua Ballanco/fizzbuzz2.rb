#!/usr/bin/env ruby -w

require 'monitor'
class FizzThreader
  attr_reader :counting

  def initialize
    @counting = 1
    @fizz_went = false
    @buzz_went = false
    @numbers_went = false
    @done_counting = false
    @output = ''
    @output.extend(MonitorMixin)
  end

  def fizz
    Thread.new do
      loop do
        @output.synchronize do
          if !@fizz_went && !@buzz_went && !@numbers_went
            @output << 'Fizz' if @counting%3 == 0
            @fizz_went = true
          end
        end
        break if @done_counting && @fizz_went
      end
    end
  end

  def buzz
    Thread.new do
      loop do
        @output.synchronize do
          if @fizz_went && !@buzz_went && !@numbers_went
            @output << 'Buzz' if @counting%5 == 0
            @buzz_went = true
          end
        end
        break if @done_counting && @buzz_went
      end
    end
  end

  def numbers
    Thread.new do
      loop do
        @output.synchronize do
          if @fizz_went && @buzz_went && !@numbers_went
            @output << @counting.to_s unless (@counting%3 == 0 || @counting%5 == 0)
            @numbers_went = true
          end
        end
        break if @done_counting && @numbers_went
      end
    end
  end

  def count_upto(i)
    Thread.new do
      loop do
        @output.synchronize do
          if @fizz_went && @buzz_went && @numbers_went
            @output << "\n"
            @counting += 1
            @done_counting = true if @counting >= i
            @fizz_went = false
            @buzz_went = false
            @numbers_went = false
          end
        end
        break if @done_counting
      end
    end
  end

  def start_counting_upto(i)
    @counting_threads = []
    @counting_threads << fizz
    @counting_threads << buzz
    @counting_threads << numbers
    @counting_threads << count_upto(i)
    @counting_threads.each {|thr| thr.join}
    @output
  end

end

fizzy_threads = FizzThreader.new
puts fizzy_threads.start_counting_upto(100)
