#require '61'
require '61alt'

d = Dice.new(ARGV[0])
(ARGV[1] || 1).to_i.times { print "#{d.roll} " }
puts ''
