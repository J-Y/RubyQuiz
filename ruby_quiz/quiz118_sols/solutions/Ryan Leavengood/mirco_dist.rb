# Ruby Quiz #118: Microwave
# Solution by Ryan Leavengood
# I'm glad to be back...

require 'test/unit'

class Microwave
 # Finds the most efficient button combo for the given seconds and metric
 def self.microwave(seconds, metric = proc {|b| euclidean_distance(b)})
   generate_buttons(seconds).sort_by(&metric).first
 end

 # Allows a tolerance when finding the most efficient button combo
 def self.microwave_give_or_take(seconds, tolerance,
                                 metric = proc {|b| euclidean_distance(b)})
   ((seconds-tolerance)..(seconds+tolerance)).map do |s|
     generate_buttons(s)
   end.flatten.sort_by(&metric).first
 end

 # Generates the various button combinations for the given seconds
 def self.generate_buttons(seconds)
   result = []
   if seconds < 100
     result << seconds
   end
   if seconds > 59
     min,sec = seconds.divmod(60)
     result << "#{min}#{"%02d" % sec}".to_i
     if min > 1 and sec < 40
       sec += 60
       min -= 1
       result << "#{min}#{"%02d" % sec}".to_i
     end
   end

   result.sort
 end

 # The default button layout
 @points = {
   '1' => [0,0],
   '2' => [0,1],
   '3' => [0,2],
   '4' => [1,0],
   '5' => [1,1],
   '6' => [1,2],
   '7' => [2,0],
   '8' => [2,1],
   '9' => [2,2],
   '0' => [3,1],
   '*' => [3,2]
 }

 # Traverses the buttons calculating Euclidean distance
 def self.euclidean_distance(buttons, points = @points)
   button_path_distance(buttons, :calc_euclidean_distance, points)
 end

 # Traverses the buttons calculating Manhattan distance
 def self.manhattan_distance(buttons, points = @points)
   button_path_distance(buttons, :calc_manhattan_distance, points)
 end

 # Surprise, surprise this gives the number of buttons pressed
 def self.number_of_buttons(buttons)
   # The +1 adds the * button
   buttons.to_s.length + 1
 end

 private

 # The worker function for getting button distance
 def self.button_path_distance(buttons, method, points)
   result = 0.0
   # Get each digit as a string and add the * for the cook button,
   # then convert to the points the buttons represent
   sequence = (buttons.to_s.scan(/./) << '*').map { |b| points[b] }
   start = sequence.shift
   sequence.each do |point|
     result += self.send(method, start, point)
     start = point
   end
   result
 end

 def self.calc_euclidean_distance(start_point, end_point)
   Math.sqrt(
     ((end_point[0] - start_point[0]) ** 2) +
     ((end_point[1] - start_point[1]) ** 2))
 end

 def self.calc_manhattan_distance(start_point, end_point)
   (end_point[0] - start_point[0]).abs +
     (end_point[1] - start_point[1]).abs
 end
end

# Defining the method requested in the quiz
def microwave(seconds)
 Microwave.microwave(seconds)
end

# A pretty darn thorough test case...I did this all test first
class MicrowaveTest < Test::Unit::TestCase
 def test_microwave
   assert_equal(1, microwave(1))
   assert_equal(10, microwave(10))
   assert_equal(35, microwave(35))
   assert_equal(45, microwave(45))
   assert_equal(60, microwave(60))
   assert_equal(74, microwave(74))
   assert_equal(99, microwave(99))
   assert_equal(140, microwave(100))
   assert_equal(159, microwave(119))
   assert_equal(200, microwave(120))
   assert_equal(199, microwave(159))
   assert_equal(240, microwave(160))
   assert_equal(780, microwave(500))
   assert_equal(1700, microwave(1020))
 end

 def test_give_or_take
   # I was lazy and only decided to test for the given case :)
   assert_equal(99, Microwave.microwave_give_or_take(95, 5))
 end

 def test_generate_buttons
   assert_equal([1], Microwave.generate_buttons(1))
   assert_equal([13], Microwave.generate_buttons(13))
   assert_equal([27], Microwave.generate_buttons(27))
   assert_equal([55], Microwave.generate_buttons(55))
   assert_equal([60,100], Microwave.generate_buttons(60))
   assert_equal([68,108], Microwave.generate_buttons(68))
   assert_equal([75,115], Microwave.generate_buttons(75))
   assert_equal([99,139], Microwave.generate_buttons(99))
   assert_equal([140], Microwave.generate_buttons(100))
   assert_equal([141], Microwave.generate_buttons(101))
   assert_equal([159], Microwave.generate_buttons(119))
   assert_equal([160,200], Microwave.generate_buttons(120))
   assert_equal([188,228], Microwave.generate_buttons(148))
   assert_equal([199,239], Microwave.generate_buttons(159))
   assert_equal([240], Microwave.generate_buttons(160))
   assert_equal([250], Microwave.generate_buttons(170))
   assert_equal([259], Microwave.generate_buttons(179))
   assert_equal([260,300], Microwave.generate_buttons(180))
   assert_equal([780,820], Microwave.generate_buttons(500))
   assert_equal([1645], Microwave.generate_buttons(1005))
   assert_equal([1660,1700], Microwave.generate_buttons(1020))
 end

 def test_euclidean_distance
   assert_in_delta(3.61, Microwave.euclidean_distance(1), 0.01)
   assert_in_delta(3.61, Microwave.euclidean_distance(11), 0.01)
   assert_in_delta(3.16, Microwave.euclidean_distance(2), 0.01)
   assert_in_delta(3.16, Microwave.euclidean_distance(22), 0.01)
   assert_in_delta(3.0, Microwave.euclidean_distance(3), 0.01)
   assert_in_delta(3.0, Microwave.euclidean_distance(33), 0.01)
   assert_in_delta(2.83, Microwave.euclidean_distance(4), 0.01)
   assert_in_delta(2.83, Microwave.euclidean_distance(44), 0.01)
   assert_in_delta(2.24, Microwave.euclidean_distance(5), 0.01)
   assert_in_delta(2.24, Microwave.euclidean_distance(55), 0.01)
   assert_in_delta(2.0, Microwave.euclidean_distance(6), 0.01)
   assert_in_delta(2.0, Microwave.euclidean_distance(66), 0.01)
   assert_in_delta(2.24, Microwave.euclidean_distance(7), 0.01)
   assert_in_delta(2.24, Microwave.euclidean_distance(77), 0.01)
   assert_in_delta(1.41, Microwave.euclidean_distance(8), 0.01)
   assert_in_delta(1.41, Microwave.euclidean_distance(88), 0.01)
   assert_in_delta(1.0, Microwave.euclidean_distance(9), 0.01)
   assert_in_delta(1.0, Microwave.euclidean_distance(99), 0.01)
   assert_in_delta(1.0, Microwave.euclidean_distance(0), 0.01)
   assert_in_delta(5.0, Microwave.euclidean_distance(123), 0.01)
   assert_in_delta(4.16, Microwave.euclidean_distance(100), 0.01)
   assert_in_delta(3.83, Microwave.euclidean_distance(159), 0.01)
 end

 def test_manhattan_distance
   assert_equal(5, Microwave.manhattan_distance(1))
   assert_equal(5, Microwave.manhattan_distance(11))
   assert_equal(4, Microwave.manhattan_distance(2))
   assert_equal(4, Microwave.manhattan_distance(22))
   assert_equal(3, Microwave.manhattan_distance(7))
   assert_equal(3, Microwave.manhattan_distance(777))
   assert_equal(5, Microwave.manhattan_distance(100))
 end

 def test_number_of_buttons
   assert_equal(2, Microwave.number_of_buttons(1))
   assert_equal(3, Microwave.number_of_buttons(12))
   assert_equal(4, Microwave.number_of_buttons(567))
   assert_equal(5, Microwave.number_of_buttons(1000))
 end
end

if $0 == __FILE__
 if ARGV.length > 0
   if ARGV[0] =~ /^\d*$/
     seconds = ARGV[0].to_i
     puts "For #{seconds} seconds the ideal minimum microwave buttons are:"
     puts "\t#{microwave(seconds)} using Euclidean distances"
     puts "\t#{Microwave.microwave(seconds, proc{|b| Microwave.manhattan_distance(b)})} using Manhattan distances"
     puts "\t#{Microwave.microwave(seconds, proc{|b| Microwave.number_of_buttons(b)})} using number of buttons"
     puts "\t#{Microwave.microwave_give_or_take(seconds, 5)} using Euclidean distances and a 5 second threshold"
     puts "\t#{Microwave.microwave_give_or_take(seconds, 10)} using Euclidean distances and a 10 second threshold"
     wide_points = {
       '1' => [0,0],
       '2' => [0,2],
       '3' => [0,4],
       '4' => [1,0],
       '5' => [1,2],
       '6' => [1,4],
       '7' => [2,0],
       '8' => [2,2],
       '9' => [2,4],
       '0' => [3,2],
       '*' => [3,4]
     }
     puts "\t#{Microwave.microwave(seconds, proc{|b| Microwave.euclidean_distance(b, wide_points)})} using Euclidean distances and wide buttons"
   else
     puts "Usage: #$0 <seconds> (or nothing to run the test cases)"
     exit(1)
   end
   # Don't run the test case
   Test::Unit.run = true
 end
end
