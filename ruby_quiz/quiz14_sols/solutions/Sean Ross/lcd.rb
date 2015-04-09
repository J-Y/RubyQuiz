# lcd.rb
require 'optparse'

opts = OptionParser.new
size = 2 # default
opts.on("-s","--size VAL", Integer){|val| size=val}
digit_entry = opts.parse(*ARGV).first

raise "size must be greater than zero (given #{size})" if size <= 0
raise "'#{digit_entry}' contains non-digit characters" if digit_entry =~ /\D/

# to hold LCD format information
LCD = Struct.new(:upper_crossbar, :upper_uprights,
                 :middle_crossbar,:lower_uprights,:lower_crossbar)

# lcd segment formats
gap = ' '*size
nothing   = " #{gap} "
crossbar  = " #{'-'*size} "
leftpost  = "|#{gap} "
rightpost = " #{gap}|"
uprights  = "|#{gap}|"

# digits in LCD format
LCDs = {'0'=>LCD[crossbar,uprights,nothing,uprights,crossbar],
        '1'=>LCD[nothing,rightpost,nothing,rightpost,nothing],
        '2'=>LCD[crossbar,rightpost,crossbar,leftpost,crossbar],
        '3'=>LCD[crossbar,rightpost,crossbar,rightpost,crossbar],
        '4'=>LCD[nothing,uprights,crossbar,rightpost,nothing],
        '5'=>LCD[crossbar,leftpost,crossbar,rightpost,crossbar],
        '6'=>LCD[crossbar,leftpost,crossbar,uprights,crossbar],
        '7'=>LCD[crossbar,rightpost,nothing,rightpost,nothing],
        '8'=>LCD[crossbar,uprights,crossbar,uprights,crossbar],
        '9'=>LCD[crossbar,uprights,crossbar,rightpost,crossbar]}

# simulate LCD panel display
digits = digit_entry.split(//).collect{|d| LCDs[d]}
LCD.members.each_with_index do |segment_name, index|
    panel_segment = digits.collect{|lcd| lcd[segment_name]}.join(' ')
    repeat = index%2==0 ? 1 : size # only repeat 'upright' segments
    repeat.times{puts panel_segment}
end
