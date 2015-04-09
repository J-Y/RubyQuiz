####################
# Expected: "1,999,995.99"
quiz = 1999995.99
a=quiz.to_s.split'.';r=a[0].reverse.gsub(/\d{3}\B/, '\0,').reverse+".#{a[1]}"
puts r

####################
# Expected: [1, 2, [3]]
quiz = [1, [2, [3]]]
r = []; quiz.each{|e| [*e].each {|x| r << x}}; r
puts r.inspect

####################
# Expected: a shuffled array
quiz = [1, 2, 3, 4, 5]
r = quiz.sort_by{rand}
puts r.inspect

####################
# Expected: the actual class object
module GhostWheel; module Expression; class LookAhead; end; end; end
quiz = "GhostWheel::Expression::LookAhead"
r = quiz.split(/::/).inject(Kernel){|t,k| t.const_get(k)}
puts r

####################
# Expected: "aaaaaaaaaaaaaaaaaaaa"
# "bbbbbbbbbbbbbbbbbbbb cccccccccccccccccc"
# "dddddddddddddddddddd"
quiz = "a" * 20 + " " + "b" * 20 + " " + "c" * 18 + " " + "d" * 20
r = quiz.gsub(/(.{1,40}) /, "\\1\n")
puts r

####################
# Expected: ["foo", "oof", "ofo"]
quiz = %w[foo bar baz oof foobar ofo]
$; = //; f = quiz[0].split.sort; r = quiz.select{|e| e.split.sort == f}
puts r
$; = nil

####################
# Expected: "111100111011111110101"
# "110000111100101100101"
# "1100100111010111011011100010"
quiz = "You are dumb"
r = quiz.gsub(/./) {|c| (c == ' ') ? "\n" : ("%08b" % c[0])}
puts r

####################
# Expected: a random line from the this File
File.open(__FILE__, "r") do |quiz|
  a = quiz.read.split("\n"); r = a[rand(a.size)]
end
puts r

####################
# Expected: [15, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1]
quiz = 15
r = [quiz]; while ((e = r.last) != 1) do r<<((e%2==0)?e/2:3*e+1) end; r
puts r.inspect

####################
# Expected: {"one" => {"two" => {"three" => {"four" => "five"}}}}
quiz = %w[one two three four five]
r = quiz.reverse.inject{|h,v| {v=>h}}
puts r.inspect
