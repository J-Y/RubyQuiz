#!/usr/bin/ruby
# This solution still uses Jim Weirich's Amb class
# but this time it is inlined into the Chess960 class
# and adapted for the exact problem.
# As a matter of fact we do not use assert as
# the constraints for the positions can be expressed
# declaratively, all work Amb has to do is the callcc trick
# to back up to the next solution
#
class Chess960
 ExhaustedError = Class.new RuntimeError

 # We use objects which respond to #each already
   # optimize the calls so that we do not have to splat
 def choose(choices)
   choices.each { |choice|
           # avoid any duplicate positions
           if @free.delete( choice ) then
               callcc { |fk|
                   @back << fk
                   return choice
               }
               @free.unshift choice
           end
   }
   failure
 end

 def failure
   @back.pop.call
 end

   N = 8
   Queen = ?Q
   King = ?K
   Rook = ?R
   Bishop = ?B

   attr_accessor :b1, :b2, :r1, :r2, :k, :q
   attr_reader :solutions

   # prepare the constraints
   LeftBishop = proc {
       @b1 = choose 1..N-1
   }
   RightBishop = proc {
       @b2 = choose( (@b1.succ..N).select{ |b| b & 1 != @b1 & 1 } )
   }
   LeftRook = proc {
       @r1 = choose 1..N-2
   }
   SoleKing = proc {
       @k = choose @r1.succ..N-1
   }
   RightRook = proc {
       @r2 = choose @k.succ..N
   }
   SoleQueen = proc {
       @q = choose 1..N
       save_solution
   }

   def initialize
       @free = [*1..8]
   @back = [
     lambda { fail ExhaustedError }
   ]
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
   # So all boils down to place the pieces ;)
   def generate
       instance_eval( &LeftBishop )
       instance_eval( &RightBishop )
       instance_eval( &LeftRook )
       instance_eval( &SoleKing )
       instance_eval( &RightRook )
       instance_eval( &SoleQueen )
       rescue ExhaustedError
   end
   def save_solution
       @sol[2*(b1-1)]= Bishop
       @sol[2*(b2-1)]= Bishop
       @sol[2*(r1-1)]= Rook
       @sol[2*(r2-1)]= Rook
       @sol[2*(q-1)]= Queen
       @sol[2*(k-1)]= King
       @solutions << @sol
       init
       # force another solution if there is one
       failure
   end

end

c = Chess960.new
puts %<enter a number to show a specific solution (0 based) or
enter r for a random solution or
enter a to see all solutions
enter q to go back to work>
until (n = gets.strip) =~ /^q/i
   if n =~ /^a/i then
       c.solutions.each_with_index do
           |sol, i|
           puts "%3d: %s" % [i, sol]
       end
       next
   end
   i = n.to_i
   i = rand(960) if n =~ /^r/i
   puts "%3d: %s" % [i, c [i]]
end

