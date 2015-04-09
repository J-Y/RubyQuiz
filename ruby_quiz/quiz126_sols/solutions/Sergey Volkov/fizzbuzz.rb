#!/bin/env ruby

=begin
"Ruby Quiz" <james@grayproductions.net> wrote in message 
news:20070601122814.XMOR28308.eastrmmtao105.cox.net@eastrmimpo02.cox.net...
..
Write a program that prints the numbers from 1 to 100.
But for multiples of three print "Fizz" instead of the
number and for the multiples of five print "Buzz". For
numbers which are multiples of both three and five
print "FizzBuzz".

Pretend you've just walked into a job interview and been hit with this 
question.
Solve it as you would under such circumstances for this week's Ruby Quiz.

The task itself is quite boring, so I decided to imagine how
different programmers may try to pass the interview.
I hope we'll see what the recruiter may think.

Oh! And I played golf, just for fun, hope you will enjoy it too.
=end

##
# Q126 solution
# by Sergey Volkov
##

##
# job interview style
##
# Java programmer
def sol1 maxn=100
    for i in 1..maxn
        if i%3 == 0 && i%5 == 0
            puts "FizzBuzz"
        elsif i%3 == 0
            puts "Fizz"
        elsif i%5 == 0
            puts "Buzz"
        else
            puts i
        end
    end
end
puts '### TC1'
sol1 15

##
# Same as above,
# but the code is more manageable
def sol1a maxn=100
    for i in 1..maxn
        if i%3 == 0 && i%5 == 0
            s = "FizzBuzz"
        elsif i%3 == 0
            s = "Fizz"
        elsif i%5 == 0
            s = "Buzz"
        else
            s = i.to_s
        end
        puts s
    end
end
puts '### TC1a'
sol1a 15

##
# Lisp programmer
def sol2 maxn=100
    puts( (1..maxn).map{ |i|
        i2s=lambda{ |n,s|
            if (i%n).zero? : s else '' end
        }
        lambda{ |s|
            if s.empty? : i else s end
        }.call i2s[3,'Fizz'] + i2s[5,'Buzz']
    } )
end
puts '### TC2'
sol2 15

##
# 1 year of Ruby experience
def sol3 maxn=100
    1.upto(maxn){ |n|
        s = "Fizz" if (n%3).zero?
        (s||='') << "Buzz" if (n%5).zero?
        puts s||n
    }
end
puts '### TC3'
sol3 15

##
# Trying to get extra points for reusability..
class Fixnum
    def toFizzBuzz
        s = 'Fizz' if modulo(3).zero?
        s = "#{s}Buzz" if modulo(5).zero?
        s || to_s
    end
end
def sol4 maxn
    1.upto(maxn){ |n| puts n.toFizzBuzz }
end
puts '### TC4'
sol4 15

##
# Extra points for expandability
#.. who knows what else recruiters are looking for?

__END__

##
# Golf style
1.upto(?d){|i|puts ["#{x=[:Fizz][i%3]}Buzz"][i%5]||x||i}# 56
1.upto(?d){|i|x=[:Fizz][i%3];puts i%5<1?"#{x}Buzz":x||i}# 56
1.upto(?d){|i|i%3<1&&x=:Fizz;puts i%5<1?"#{x}Buzz":x||i}# 56
