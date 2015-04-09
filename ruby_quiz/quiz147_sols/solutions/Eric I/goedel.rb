require 'mathn'  # for Prime class


# Put the coder in a separate class, so we have the potential to use
# other coders, such as the one from the Starburst novel.
class RubyQuizCoder
  def encode(char)
    char[0] + 1
  end

  def decode(number)
    (number - 1).chr
  end

  def max_code
    127
  end
end


def encode(input, primes, coder)
  goedel_value = 1

  input.each_line do |line|
    0.upto(line.size - 1) do |i|
      char = line[i, 1]
      encoding = coder.encode char
      next if encoding.nil?  # skip characters without encoding
      goedel_value *= primes.next ** encoding
    end
  end

  puts goedel_value
end


# Attempt to decode quickly by trying to perfectly divide by
# prime**(2**6), prime**(2**5), prime**(2**4), ..., prime**(2**0) and
# then adding the powers of 2 for which the division worked without a
# remainder.  For example, if a number were divisible by prime**101,
# then it's also divisible by prime**64 * prime**32 * prime**4 *
# prime**1 since 64 + 32 + 4 + 1 = 101.  So, we'll have to divide the
# large number exactly 7 times per prime no matter what the exponent.
# Note: 7 assumes that the encoding results in no value greater than
# 127.
def decode(input, primes, coder)
  goedel_value = input.gets.to_i
  max_two_expnt = (Math.log(coder.max_code) / Math.log(2)).to_i
  factors = (0..max_two_expnt).map { |i| [2**i, nil] }

  while goedel_value > 1
    current_prime = primes.next
    encoded = 0

    factors[0][1] = current_prime
    (1..max_two_expnt).each do |i|
      factors[i][1] = factors[i - 1][1] ** 2
    end

    factors.reverse_each do |expnt, factor|
      quotient, remainder = goedel_value.divmod(factor)
      if remainder == 0
        encoded += expnt
        goedel_value = quotient
      end
    end

    char = coder.decode(encoded)
    putc char unless char.nil?
  end
end


def usage
  STDERR.puts "Usage: %s -e[ncode]|-d[ecode] [file]" % $0
  exit 1
end


# process command-line args and figure out which method to call

task = nil
input = nil
ARGV.each do |arg|
  case arg
  when /^-+e/   : task = :encode
  when /^-+d/   : task = :decode
  else if input : usage
       else       input = open(arg)
       end
  end
end

input = STDIN if input.nil?
primes = Prime.new
coder = RubyQuizCoder.new

case task
when :encode : encode(input, primes, coder)
when :decode : decode(input, primes, coder)
else           usage
end
