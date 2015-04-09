# * Convert an Array of objects to nested Hashes such that %w[one two three four
# five] becomes {"one" => {"two" => {"three" => {"four" => "five"}}}}.
#...+....|....+....2....+....|....+....|....+....5....+....|....+....|....+....8
quiz[0..-3].reverse.inject( { quiz[-2] => quiz[-1] } ){ |h,e| { e => h } }
# or
# quiz.inject{|arr,ele| [*arr].push(*ele)}
