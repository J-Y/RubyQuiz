# If multiple solutions exist that have the same number of coins,
# the winning answer is determined by the value of 'avoid_pennies':
#   If true, whichever answer gives the biggest of the small change is used.
#   If false, whichever answer gives the biggest of the large change is used.
def make_change( amount, coins=[25,10,5,1], avoid_pennies=true, recursing=false )
 # Don't sort in place, in case the user wants to preserve the coin array
 coins  = coins.sort_by{ |coin| -coin }
 owed   = amount
 change = []
 coins.each{ |coin|
   while owed >= coin
     owed -= coin
     change << coin
   end
 }
 change = nil unless owed == 0

 if recursing
   change
 else
   answers = [ change ]
   while coins.shift
     answers << make_change( amount, coins, avoid_pennies, true )
   end
   answers.compact.sort_by{ |answer|
     [
       answer.length,
       -answer.send( avoid_pennies ? :last : :first )
     ]
   }.first
 end
end
