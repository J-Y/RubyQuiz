require 'fuzzy_time'
require 'test/unit'
class TestFuzzyTime < Test::Unit::TestCase
 def test_in_range
   @bore_level = 100000
   @ft = FuzzyTime.new(Time.new, :hidden_digits => 0)
   diff_coll = Hash.new(0)
   @bore_level.times do
     previous = @ft.to_s
     @ft.advance(60)
     actual = @ft.actual.strftime('%H%M').to_i
     printed = @ft.to_s.sub(':', '').to_i
     difference = actual - printed
     #puts "actual #{actual} printed #{printed} difference #{difference}"
     unless printed.to_s =~ /\d*5[4-9]/ || actual.to_s =~ /\d*5[4-9]/
       diff_coll[difference] += 1
       raise "actual #{actual.to_s} previous #{printed} difference #{difference}" if difference > 5
       assert (difference.abs <= 5)
     end
   end
   total = diff_coll.values.inject(0) {|sum, value| sum + value}
   (-5..5).each {|num| puts [num,
(diff_coll[num])*100/total.to_f].join(' -> ')}
 end
end
