#!/usr/local/bin/ruby -w

PRIMES = [2,3]

# Work out what the x'th prime is, starting from 0.
# Uses the PRIMES array, declared above.
# The algorithm is based on:
#   k is prime if no number other than 1 divides it.
#   If some n divides it then n * m = k, so one of 
#   these must be <= sqrt(k), so we only need to search
#   up to n: n * n = k.  If some n divides it, then 
#   if that n is not prime, it has prime factors. Else it
#   must be prime itself.  So we only need to search through
#   the list of primes found so far, rather than testing all
#   possible factors.
def primes(x)
  # puts "x is #{x}"
  if x < PRIMES.size 
    return PRIMES[x]
  else
    k = PRIMES[PRIMES.size - 1] + 1
    # puts "k is #{k}, PRIMES.size is #{PRIMES.size}"
    while (PRIMES.size <= x)
      # puts "k is #{k}"
      is_prime = true
      0.upto(PRIMES.size) do |i|
        p = PRIMES[i]
        break if p.nil?
        break if p * p > k
        quot = k / p
        if (k == quot * PRIMES[i]) then
           is_prime = false
           # puts "#{k} is not prime"
           break
        end
      end
      PRIMES << k if is_prime
      k += 1
    end
    return PRIMES[x]
  end
end

#Goedelize the message in the string. Uses ASCII+1 encoding
#rather than that used in Starburst, because it was easiest
#to code.
def goedelize(message)
  code = 1
  count = 0
  message.each_byte do |b|
    code *= primes(count) ** (b+1)
    count += 1
  end 
  return code
end 

# This is used by goedelize2 to speed up the search for
# the power of some prime that divides the number.
# If p ** k divides n, then the highest value of k must
# be >= k. Search until we find that highest power.
# Normal binary search puts the midpoint on one side,
# but we need to keep the greatest power found so far
# in case we don't find a bigger one.
def binary_search(n, p, lo, hi)
  # puts "binary_search(#{n}, #{p}, #{lo}, #{hi})"
  # puts "binary_search(n, #{p}, #{lo}, #{hi})"
  if lo > hi
    raise "not found, #{lo}, #{hi}"
  end
  if lo == hi
    return lo
  else
    mid = (lo + hi) / 2
    if mid == lo
      return mid
    end
    guess = p ** mid 
    # quot = n / guess
    # if quot * guess == n
    if n.remainder(guess).zero?
      return binary_search(n, p, mid, hi)
    else
      return binary_search(n, p, lo, mid)
    end
  end
end

# Convert the character code (number), to a character
# according to the encoding.  The encoding in Starburst
# on page 58 is of the form "A => 1, B => 2,...", with
# an example where space is coded as 0.  Otherwise there
# seems to be no punctuation.  Hence my extending this to
# complete bytes, by default.  Clearly this could be further
# extended to UTF16, UTF32...
def decode(code, encoding)
  result = ""
  case encoding
  when :ascii
    result += (code-1).chr
  else
    case code
    when 0
      result += " "
    when 1..26
      # 1 = A, 2 = B...
      result += (code+64).chr
    else
      result += "."
    end
  end
  return result
end

# This is like degoedelize, only instead of searching for the
# index (power) by counting up, it uses a binary search strategy.
# For a byte this should be only about 8 tests, rather than about
# 128 on average.
def degoedelize2(n,encoding=:ascii)
  result = ""
  quot = n
  i = 0
  p = primes(i)
  while quot > 1
    # puts "quot = #{quot}"
    # puts "p = #{p}"
    if quot.remainder(p).zero?
      puts "quot is #{quot.to_s.size} digits, p is #{p.to_s.size} digits"
      code = binary_search(quot, p, 0, 256)
      # result += (code -1).chr
      result += decode(code, encoding)
      # This next is needed as the example in the book contains a lot
      # of space it turns out.
      result.squeeze!(" \t.") if encoding == :Pohl
      puts "result = #{result}"
      quot /= (p ** code)
    else
      result += decode(0, encoding)
      result.squeeze!(" \t.") if encoding == :Pohl
    end
    i += 1
    p = primes(i)
    puts "quot is #{quot.to_s.size} digits, p is #{p.to_s.size} digits" if (i%1000).zero?
  end
  return result
end

# Increasing prime factors as we go through the 
# message, we try to find the power of that prime
# which was used to encode the message.  This is 
# p ** k is a factor of n, for the largest value of
# k.
def degoedelize(n,encoding=:ascii)
  result = ""
  quot = n
  i = 0
  p = primes(i)
  puts "p is #{p}"
  while quot > 1
    count = 0
    guess = 128
    quot = n / p
    puts "quot is now #{quot}"
    while quot * p == n
      # it is a factor
      count += 1 
      n = quot
      quot = n / p
      puts "quot is #{quot}"
      puts "count is #{count}"
      puts "i is #{i}"
      puts "p is #{p}"
    end
    if count.zero?
      puts "count unexpectedly #{count}"
    else
      result += decode(count,encoding)
      # This next is needed as the example in the book contains a
      # lot of space it turns out.
      result.squeeze!(" \t.") if encoding == :Pohl
    end
    i += 1
    p = primes(i)
    puts "i is #{i}, p is #{p}"
  end
  return result
end

if __FILE__ == $0

  if ARGV.size == 0
    # We are just running checks to see all is well.
    0.upto(20) do |x|
      puts primes(x)
    end
    message = "A rose by any other name would smell as sweet"
    g = goedelize(message)
    puts g
    sleep 5
    str = degoedelize(g)
    puts "str is #{str}"
    sleep 5
    str2 = degoedelize2(g)
    puts "str2 is #{str2}"
    puts "str == str2 is #{str == str2}"
  else
    # We are processing files.
    case ARGV[0]
    when "-d"
      # decode
      open(ARGV[1], "r") do |ifp|
        msg = ifp.read.gsub(/\s+/m, '').to_i
        open(ARGV[2], "wb") do |ofp|
          ofp.print degoedelize2(msg,:ascii)
        end
      end
    when "-e"
      # encode
      open(ARGV[1], "rb") do |ifp|
        msg = ifp.read
        open(ARGV[2], "w") do |ofp|
          ofp.print goedelize(msg)
        end
      end
    when "-p"
      # starburst by Frederik Pohl ISBN 0-345-27537-3, page 56
      # msg = (3.875 * (12 ** 26)).to_i +...  # We'd prefer this to
      # be integer, so rewrite as:
      msg = (558 * (12 ** 24)) +
            (1973 ** 854) + (331 ** 852) +
            (17 ** 2008) + (3 ** 9707) + (2 ** 88) - 78
      txt = degoedelize2(msg, :Pohl)
      puts txt
    else
      puts <<-EOM
Usage: #{$0} [-deh] [infile outfile]
where -d means decode (degoedelize)
      -e means encode (goedelize)
      -h (or anything) means help
If files are given, at the moment they must be true files, not '-'
for stdin, stdout, and both must be given.  This cannot be used
as a filter at the moment.
If no arguments are given, the program self tests.
      EOM
    end
  end
end
