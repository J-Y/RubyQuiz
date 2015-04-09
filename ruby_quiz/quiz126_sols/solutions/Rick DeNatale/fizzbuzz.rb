class Integer
 # RubyQuiz 126 Solutions by Rick DeNatale
 #
 # This quiz was simple enough that I decided to come up with as many different ways to
 # do it some simple, some rather bizzare and cryptic.

 #This one simply follows the spec pretty slavishly.
 def fizz_buzz1
   case
   when self % 15 == 0
     "FizzBuzz"
   when self % 3 == 0
     "Fizz"
   when self % 5 == 0
     "Buzz"
   else
     self.to_s
   end
 end

 # Nest the fizzbuzz test
 def fizz_buzz2
   case
   when self % 3 == 0
     self % 5 == 0 ? "FizzBuzz" : "Fizz"
   when self % 5 == 0
     "Buzz"
   else
     self.to_s
   end
 end

 # basically the same as 4 but using interpolation, and the fact that
 # 1. An array returns nil for oob indices, and
 # 3. nil.to_s returns the empty string.
 def fizz_buzz3
   case
   when self % 3 == 0
     "Fizz#{["Buzz"][self % 5]}"
   when self % 5 == 0
     "Buzz"
   else
     self.to_s
   end
 end

 # Use a mod 15 approach
 def fizz_buzz4
   ([:FizzBuzz, nil, nil, :Fizz, nil, :Buzz, :Fizz, nil, nil, :Fizz, :Buzz, nil, :Fizz][self % 15]||self).to_s
 end

 # Kids don't try this at home
 # The to_s(15) makes the last character wholly dependent on self % 15
 # Then a series of subs are used to evolve the string to the correct answer.
 def fizz_buzz5
   ("%2d,%s" % [self, to_s(15)]).sub(/.+?[369c]$/,'Fizz').sub(/.+?[0]$/,'FizzBuzz').sub(/.+?[5a]$/,"Buzz").sub(/^\s?(\d+),.*$/,'\1')
 end

 # This was really a stretch for me, since it seems the most cryptic.
 # And I HATE cryptic code.
 def fizz_buzz6
   ("%2d,%s" % [self, to_s(15)]).sub(/.+?((0|([5a]))|[369c])$/) {
     "#{$3 ? '' : 'Fizz'}#{$2 ? 'Buzz' : ''}" }.sub(/^\s?(\d+),.*$/,'\1')
 end

 # Here's another one-line method approach
 def fizz_buzz7
   (self % 15 == 0) ? "FizzBuzz" : ((self % 3 == 0) ? "Fizz" : ((self % 5 == 0) ? "Buzz" : to_s))
 end

 # And one more
 def fizz_buzz8
   "#{"Fizz" if self % 3 == 0}#{"Buzz" if self % 5 == 0}#{[nil, self][1+((self % 3)*(self % 5))]}"
 end
end

# Hand coded result for testing.
# This is arranged in rows of 15 showing the mod 15 pattern.
expected = %w{1   2  Fizz  4 Buzz Fizz  7  8 Fizz Buzz 11 Fizz 13 14 FizzBuzz
             16  17  Fizz 19 Buzz Fizz 22 23 Fizz Buzz 26 Fizz 28 29 FizzBuzz
	           31  32  Fizz 34 Buzz Fizz 37 38 Fizz Buzz 41 Fizz 43 44 FizzBuzz
	           46  47  Fizz 49 Buzz Fizz 52 53 Fizz Buzz 56 Fizz 58 59 FizzBuzz
	           61  62  Fizz 64 Buzz Fizz 67 68 Fizz Buzz 71 Fizz 73 74 FizzBuzz
	           76  77  Fizz 79 Buzz Fizz 82 83 Fizz Buzz 86 Fizz 88 89 FizzBuzz
	           91  92  Fizz 94 Buzz Fizz 97 98 Fizz Buzz
	           }

# test em all, these should all print true. Yeah, I know these should be test::unit testcases.
p (1..100).map {|i| i.fizz_buzz1} == expected
p (1..100).map {|i| i.fizz_buzz2} == expected
p (1..100).map {|i| i.fizz_buzz3} == expected
p (1..100).map {|i| i.fizz_buzz4} == expected
p (1..100).map {|i| i.fizz_buzz5} == expected
p (1..100).map {|i| i.fizz_buzz6} == expected
p (1..100).map {|i| i.fizz_buzz7} == expected
p (1..100).map {|i| i.fizz_buzz8} == expected
# and now two one liners
p (1..100).map {|i| (i % 15 == 0) ? "FizzBuzz" : ((i % 3 == 0) ? "Fizz" : ((i % 5 == 0) ? "Buzz" : i.to_s))} == expected
p (1..100).map {|i| "#{"Fizz" if i % 3 == 0}#{"Buzz" if i % 5 == 0}#{[nil, i][1+((i % 3)*(i % 5))]}"} == expected
# Now lets use one of these to actually print
(1..100).each {|i| p i.fizz_buzz1}
