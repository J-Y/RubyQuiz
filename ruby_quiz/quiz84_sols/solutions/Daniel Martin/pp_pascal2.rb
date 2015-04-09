#!ruby
# solution to quiz 84

require 'enumerator'
# lnnb stands for "ln of n-bang"
# value is from Stirling's approximation
def lnnb(n)
  return 0 if n <= 1
  n*Math.log(n) - n +
    Math.log(2*n*Math::PI)/2 + 1/(12*n) - 1/(360*n*n*n);
end

# how many digits in the largest number in row "n"
# where the rows get counted from 0
def npasdig(n)
  return 1 if (n < 5)
  nh = n/2
  ((lnnb(n)-lnnb(nh)-lnnb(n-nh))/Math.log(10)).ceil
end

def pp_pascal(n)
  width = npasdig(n-1)
  fmt = "%0s" + "%-#{width}s" * (2*n-2) + "%1s"
  g = Object.new
  class << g
    def coerce(o); 0.coerce(o); end
    def +(o); o; end
    def to_s; ""; end
    def inspect; "g"; end
  end
  row = [g]*(2*n+1)
  row[n] = 1
#  p fmt
  while true do
#    p row
    puts(fmt % row)
    return if row[1] == 1
    row = row.enum_cons(3).map{|a,b,c|a+c}
    row = [g] + row + [g]
  end
end

if __FILE__ == $0
  n = 4
  n = ARGV[0].to_i if ARGV[0]
  pp_pascal(n)
end

__END__
