# Ruby Quiz 111 (toothpicks)
# Krishna Dole

require 'mathn'

# Combines 2s and 3s into 4s and 6s, which are more toothpick-efficient.
# Takes a 'prime division' argument such as [[2,3], [3,2]], which it
# would return as [[3,1], [4,1], [6,1]]. The primes must be in order.
def merge_primes(pd)
  if pd[0] && pd[0][0] == 2 
    if pd[0][1] > 1
      pd << [4, (pd[0][1] / 2).to_i] # for some bizarre reason i have to call to_i here to avoid a fraction
      pd[0][1] = pd[0][1] % 2
    end
    if pd[1] && pd[1][0] == 3 && pd[0][1] == 1
      pd << [6, 1]
      pd[1][1] -= 1
      pd[0][1] -= 1
    end
  end
  pd.reject{|e| e[1] == 0}
end
  
# Expects an array of 'prime division'-like objects
def to_toothpicks(ar)
  ar.map { |pd|
    pd.map {|e| Array.new(e[1]){|i| "|" * e[0]}}.join("x")
  }.join "+"
end


# Expects an array of 'prime division'-like objects
def cost(ar)
  c = 0
  for pd in ar
    for i, n in pd
      c += i*n + n*2
    end
  end
  c -= 2
end

# Returns an array of 'prime division'-like objects
def best_toothpicks(i)
  options = []
  rem = 0
  
  if i < 8 || i == 11
    options <<  [[[i, 1]]]
  else 
    while true
      ar = i.prime_division
      option = [merge_primes(ar)]
      option += best_toothpicks(rem) if rem > 0
      options << option
      
      # this is something i'm not happy about. larger numbers (7) improve performance,
      # but i'm afraid smaller ones (3) may find better solutions
      if ar.detect {|e| e.first > 5 }
        i -= 1
        rem += 1
      else
        break
      end
    end
  end
  return options.min {|a, b| cost(a) <=> cost(b) }
end

i = ARGV[0].to_i
puts to_toothpicks(best_toothpicks(i))