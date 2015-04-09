#!/usr/bin/env ruby
# Douglas Meyer

(1..100).zip((([nil]*2<<'Fizz')*34),([nil]*4<<'Buzz')*20){|x,*y| puts
(y.compact.empty? ? x : y.join())}
