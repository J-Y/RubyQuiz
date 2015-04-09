puts( %w{ Fizz Buzz FizzBuzz } * 33 + [*1..100].reject{|n|
(n%3*n%5).zero?  }.sort_by{ |n| exercise_is_left_to_the_reader n
}[0..99].join("\n") )
