#!ruby
# solution to Ruby quiz #84

# lnnb stands for "ln of n-bang"
# value is from Stirling's approximation
def lnnb(n); 
  n*Math.log(n)-n+Math.log(2*n*Math::PI)/2 + 1/(12*n) - 1/(360*n*n*n);
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
  fmt = "%#{width}s" * (2*n-1) 
  row = [0] * (n-1) + [1] + [0] * n
  while true do
    puts(fmt % row.map{|a|if a==0 then "" else a end})
    return if row[0] > 0
    row = row[1,2*n].zip([0]+row).map{|a,b|a+b}+[0]
  end
end

if __FILE__ == $0
  n = 4
  n = ARGV[0].to_i if ARGV[0]
  pp_pascal(n)
end
