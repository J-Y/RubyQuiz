#!/usr/bin/ruby
# This solution uses a cut down version of Jim Weirich's Amb class
# submitted to Ruby Quiz # 70. Hope that's ok?
#
#  The purpose of this solution is to show how #generate becomes more
readable
#  and there is a fix of the "place 2 Knights instead of 1 Queen" error.
class Amb
 class ExhaustedError < RuntimeError; end

 def initialize
   @fail = proc { fail ExhaustedError, "amb tree exhausted" }
 end

 def choose(*choices)
   prev_fail = @fail
   callcc { |sk|
     choices.each { |choice|
       callcc { |fk|
           @fail = proc {
               @fail = prev_fail
                   fk.call(:fail)
               }
               sk.call(choice)
           }
       }
       @fail.call
   }
 end

 def assert(cond)
   choose unless cond
 end
end


class Chess960
   N = 8
   Queen = ?Q
   King = ?K
   Rook = ?R
   Bishop = ?B
   def initialize
       @amb = Amb.new
       @solutions = []
       init
       generate
       raise RuntimeError, "Illegal Number of solutions #{@solutions.length}"
unless
           @solutions.length == 960
   end
   def [] sol_nb
       @solutions[ sol_nb ]
   end

   private
   def init
       @sol="N " * N
   end
   def generate
       @b1 = @amb.choose( *1..N-1 )
       @b2 = @amb.choose( *@b1.succ..N )
       @amb.assert @b1 & 1 != @b2 & 1
       @r1 = @amb.choose( *1..N-2 )
       @k = @amb.choose( *@r1.succ..N-1 )
       @r2 = @amb.choose( *@k.succ..N )
       @q = @amb.choose( *1..N )
       # This late check makes the whole thing more readable
       # we can easily afford the additional computations
       @amb.assert [@b1,@b2,@r1,@k,@r2,@q].uniq.length == 6
       save_solution
           rescue Amb::ExhaustedError
   end
   def save_solution
       @sol[2*(@b1-1)]= Bishop
       @sol[2*(@b2-1)]= Bishop
       @sol[2*(@r1-1)]= Rook
       @sol[2*(@r2-1)]= Rook
       @sol[2*(@q-1)]= Queen
       @sol[2*(@k-1)] = King
       @solutions << @sol
       init
       @amb.choose
   end

end

c = Chess960.new
puts %<enter a number to show a specific solution (0 based) or
enter r for a random solution or
enter q to go back to work>
until (n = gets.strip) =~ /^q/i
   i = n.to_i
   i = rand(960) if n =~ /^r/i
   puts "Solution #{i}"
   puts c[i]
end
