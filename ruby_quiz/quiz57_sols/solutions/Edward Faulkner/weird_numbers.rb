#!/usr/bin/ruby

def weird(max)
  primes = sieve(max*2)
  70.step(max,2){|n| 
    puts n if weird?(n,primes)
  }
end

def weird?(n,primes)
  divs = divisors(n)
  abund = divs.inject(0){|a,b| a+b} - n
  return false if abund <= 0
  return false if spfilter(n,primes)
  return false if divs.include? abund
  smalldivs = divs.reverse.select{|i| i < abund}
  not sum_in_subset?(smalldivs,abund)
end

def sum_in_subset?(lst,n)
  #p [lst,n]
  return false if n < 0
  return true if lst.include? n
  return false if lst.size == 1
  first = lst.first
  rest = lst[1..-1]
  sum_in_subset?(rest, n-first) or sum_in_subset?(rest,n)
end


def divisors(n)
  result = []
  sr = Math.sqrt(n).to_i
  (2 .. sr).each {|d|
    if n.modulo(d) == 0
      result << d
    end
  }
  return [1] if result.empty?
  hidivs = result.map {|d| n / d }.reverse
  if hidivs[0] == result[-1]
    [1] + result + hidivs[1..-1]
  else
    [1] + result + hidivs
  end
end


def spfilter(n,primes)
  m = 0
  save_n = n
  while n[0]==0
    m += 1
    n >>= 1
  end
  return false if m == 0
  low = 2
  high = 1 << (m+1)
  primes.each {|p|
    return false if p > high
    if p > low
      return true if n%p == 0
    end
  }
  raise "not enough primes while checking #{save_n}"
end

# Sieve of Eratosthenes
def sieve(max_prime)
  candidates = Array.new(max_prime,true)
  candidates[0] = candidates[1] = false
  2.upto(Math.sqrt(max_prime)) {|i|
    if candidates[i]
      (i+i).step(max_prime,i) {|j| candidates[j] = nil}
    end
  }
  result = []
  candidates.each_with_index {|prime, i| result << i if prime }
  result
end


weird(ARGV[0].to_i)
