#!ruby

$coin_spots = []

# This function returns true the first time, but sets
# things up so that reflip causes it to return false
# to the same spot in the program.
def flip_coin
  # does amb(true,false), but without all the machinery
  callcc { |c|
    $coin_spots.push(c)
    return true
  }
  false
end

# Go back to the last time flip_coin returned true, and
# make it return false this time.
def reflip
  $coin_spots.pop.call
end

def pp_pascal(n)
  ptri = {}
  n.times { |p|
    (2*n - 1).times { |q|
      g = Object.new
      class << g
        def coerce(o); 0.coerce(o); end
        def +(o); o; end
        def to_s; ""; end
        def inspect; "g"; end
      end
      ptri[[p,q]] = g
    }
  }
  # So now ptri has this grid of "g" objects, from
  # [(0 ... n), (0 ... 2*n-1)]
  # now walk down the triangle, starting at [0,n-1] and 
  # at each step flipping a coin to either increase or decrease
  # the "q" coordinate.
  if flip_coin then
    (0 ... n).inject(n-1){ |q,p|
      ptri[[p,q]] = ptri[[p,q]]+1
      q + (flip_coin ? 1 : -1)
    }
    reflip
  else
    width = (ptri[[n-1,n-1]]+ptri[[n-1,n]]).to_s.length
    fmt = ["%#{width}s"] * 2 * n
    fmt.pop
    fmt[0] = "%1s"
    fmt[-1] = "%s"
    n.times { |p|
      pascal_row = (0 ... fmt.size).map{|q| ptri[[p,q]]}
      pascal_row.zip(fmt){|v,f| print(f%v)}
      puts ""
    }
  end
end

if __FILE__ == $0
  n = 4
  n = ARGV[0].to_i if ARGV[0]
  pp_pascal(n)
end
