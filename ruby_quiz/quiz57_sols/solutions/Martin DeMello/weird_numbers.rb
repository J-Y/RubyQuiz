N = ARGV[0].to_i

# precalculate the list of primes

def primes_to(n)
  sieve = (0..n).to_a
  2.upto(n) {|i|
    next unless sieve[i]
    (i*i).step(n, i) {|j| sieve[j] = nil}
  }
  sieve[2..-1].compact
end

PRIMES = primes_to(N)

# helper method
class Array
  def bsearch(n)
    i = 0
    j = size - 1
    k = (i+j)/2
    while i < k
      if at(k) > n
	j = k
      elsif at(k) < n
	i = k
      else
	return k
      end
      k = (i+j)/2
    end
    return i
  end
end

# factorisation routines - find the prime factors, then combine them to get a
# list of all factors

def prime_factors(x)
  pf = Hash.new {|h, k| h[k] = 0}
  PRIMES.each {|p|
    break if p > x
    while x % p == 0
      pf[p] += 1
      x /= p
    end
  }
  pf
end

def expand_factors(f, pf)
  return f if pf.empty?
  p, n = pf.shift
  powers = [p]
  (n-1).times { powers << p * powers[-1] }
  g = f.dup
  powers.each {|i| f.each {|j| g << i*j } }
  expand_factors(g, pf)
end

def factors(n)
  a = expand_factors([1], prime_factors(n)).sort
  a.pop
  a
end

# and finally, the weirdness test

def weird?(n)
  fact = factors(n)
  #
  # test for abundance (sum(factors(n)) > n)
  sum = fact.inject {|a, i| a+i}
  return false if sum < n # weird numbers are abundant

  # now the hard part
  partials = [0]

  fact.each {|f|
    if sum < n
      # discard those partials that are lower than the sum of all remaining
      # factors
      i = partials.bsearch(n-sum)
      return false if partials[i] == (n-sum)
      partials = partials[(i+1)..-1]
    end

    sum -= f # sum of all remaining factors
    temp = []

    partials.each {|p|
      j = f + p
      break if j > n
      l = n - j
      next if l > sum
      return false if (j == n) or (l == sum)
      temp << j
    }

    # handwriting a merge sort didn't help :-/
    partials = partials.concat(temp).sort.uniq
  }

  return true
end

def all_weird(n)
  weird = []
  # odd numbers are not weird (unproven but true for all n < 10^17)
  2.step(n, 2) {|i| weird << i if weird?(i) }
  weird
end

require 'benchmark'

Benchmark.bm(10) {|x|
  [1000,10000,20000].each {|n|
    x.report("#{n}") {p all_weird(n)}
  }
}
