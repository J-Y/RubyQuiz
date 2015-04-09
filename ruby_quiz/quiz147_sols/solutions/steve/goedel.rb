class String
  def godelize              
    prime = 0 ; product = 1
    each_byte do |b|
      product *= (prime = prime.next_prime) ** (b+1)
    end

    product
  end

  def self.from_godel(godel_integer)
    str = ""
    $stdout.sync = true
    godel_integer.to_i.factorize.sort_by{|factor, value|factor}.each do |factor, value|
      str << (value-1).chr
    end

    str
  end
end

class Integer
  def next_prime
    n = self
    true  while !(n+=1).prime?

    n
  end

  def prime?
    return false  if [0,1].include? self.abs

    return false  if self > 2 and self%2 == 0
    (3..self/2).step(2) do |n|
      return false  if self%n == 0
    end

    true
  end

  def factorize
    factors = {} ; prime = 0 ; n = self

    while n >= prime
      prime = prime.next_prime
      count = count_factor(prime)
      
      if count > 0
        factors[prime] = count
        n /= prime**count
      end
    end

    factors
  end

  def count_factor(f)
    return 0  if self % f != 0
    
    cnt = 1 ; n = self

    cnt += 1  while (n/=f) % f == 0

    cnt
  end
end


if $0 == __FILE__
  case ARGV.shift
  when /--encode/
    puts STDIN.read.godelize.to_s(36)
  when /--decode/
    puts String.from_godel(STDIN.read.to_i(36))
  end
end