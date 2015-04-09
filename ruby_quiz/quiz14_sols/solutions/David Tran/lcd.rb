#!/usr/bin/env ruby
# Program : Ruby Quiz #14 LCD Numbers (http://www.grayproductions.net/ruby_quiz/quiz14.html)
# Author  : David Tran
# Date    : 2005-01-07

class LCD
  DEFAULT_SIZE = 2
  LCD_CODES = [   # code for digits's each horizontal line (for size == 1)
    [:h1, :v3, :h0, :v3, :h1], #0
    [:h0, :v1, :h0, :v1, :h0], #1
    [:h1, :v1, :h1, :v2, :h1], #2
    [:h1, :v1, :h1, :v1, :h1], #3
    [:h0, :v3, :h1, :v1, :h0], #4
    [:h1, :v2, :h1, :v1, :h1], #5
    [:h1, :v2, :h1, :v3, :h1], #6
    [:h1, :v1, :h0, :v1, :h0], #7
    [:h1, :v3, :h1, :v3, :h1], #8
    [:h1, :v3, :h1, :v1, :h1], #9
  ]

  def initialize(number, size)
    @number = number.to_s.split(//).collect { |c| c.to_i }
    @size = (size || DEFAULT_SIZE).to_i
    @size = DEFAULT_SIZE if @size <= 0
    @gap = ' ' # gap between each digit

    line_codes = {                      # For size == 1
      :h0 => ' ' + ' ' * @size + ' ',   # h0 = "   "
      :h1 => ' ' + '-' * @size + ' ',   # h1 = " - "
      :v0 => ' ' + ' ' * @size + ' ',   # v0 = "   " (same as h0)
      :v1 => ' ' + ' ' * @size + '|',   # v1 = "  |"
      :v2 => '|' + ' ' * @size + ' ',   # v2 = "|  "
      :v3 => '|' + ' ' * @size + '|',   # v3 = "| |"
    }

    @lines = []
    (0..4).each { |line| @lines << @number.inject('') { |s, d| s += line_codes[LCD_CODES[d][line]] + @gap } }
  end

  def each_line
    return unless block_given?
    last_line = (@size + 1) * 2
    middle_line = last_line / 2
    (0..last_line).each do |line|
      index = case line
              when 0:               0
              when 1...middle_line: 1
              when middle_line:     2
              when last_line:       4
              else                  3
              end
      yield @lines[index]
    end
  end

end

key, size = ARGV.slice!(ARGV.index('-s'), 2) if ARGV.include?('-s')
if ARGV.empty? || /^\d+$/ !~ ARGV.first
  puts "Usage:  #$0 [-s size] number"
else
  LCD.new(ARGV.first, size).each_line { |line| puts line }
end
