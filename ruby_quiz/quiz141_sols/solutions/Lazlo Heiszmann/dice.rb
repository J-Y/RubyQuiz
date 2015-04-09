#!/usr/bin/ruby

def increment(diceArray,firstIndex)
  diceArray[firstIndex] += 1
  if diceArray[firstIndex] == 7
    diceArray[firstIndex] = 1
    increment(diceArray, firstIndex + 1)
  end
end

def findFives (diceArray,fives)
  tempArray = diceArray - [5]
  if tempArray.size <= diceArray.size - fives
    true
  else
    false
  end  
end

if ARGV[0].to_s=="-v" || ARGV[0].to_s=="-s"
  dices, fives = ARGV[1].to_i, ARGV[2].to_i
else
  dices, fives = ARGV[0].to_i, ARGV[1].to_i
end
  diceArray = [0] + [1] * (dices - 1)
  results = 0
  i = 1
  while (diceArray != [6] * dices)
    increment(diceArray,0)
    if findFives(diceArray,fives)
      s = "<=="
      results += 1
    else
      s= ""
    end
    print i.to_s + "  [" + diceArray.join(",") + "] " + s + "\n" if ARGV[0].to_s=="-v" || (ARGV[0].to_s=="-s" && (i - 1) % 50000 == 0)
    i += 1 
  end


print "\n"
puts "Number of desiralble outcomes is " + results.to_s
puts "Number of possible outcomes is " + (i - 1).to_s
print "\n"
puts "Probality is " + (results.to_f / (i - 1)).to_s
