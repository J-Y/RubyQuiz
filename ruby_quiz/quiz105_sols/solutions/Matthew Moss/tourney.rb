class Integer
  def ceilPow2
     n = self - 1
     i = 1
     until (n >> i).zero?
        n |= (n >> i)
        i *= 2
     end
     n += 1
  end

  def even?
     (self % 2).zero?
  end
end

class Array
  def fold
     raise ArgumentError unless size.even?
     h = size / 2
     self[0,h].zip(self[h,h].reverse)
  end
end

def matchup(n)
  raise ArgumentError unless n > 0

  byes = n.ceilPow2 - n
  mups = (1..n).to_a + [nil] * byes

  until mups.size == 1
     mups = mups.fold
  end

  mups[0]
end

def report(mups)
  # Here is where you could do tree output or similar... but I've no time.
  p mups
end

numTeams = (ARGV[0] || 23).to_i
if numTeams < 2
  puts "C'mon, that's not much of a competition..."
else
  matchUps = matchup(numTeams)
  report(matchUps)
end
