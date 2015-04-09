#!/usr/bin/ruby

# read the binary table upfront
f=File.open("packed-ip.dat","rb")
table=f.read
record_max=table.length/10-1
f.close

# take command line or stdin -- the latter has performance advantage for long lists
if ARGV[0]
  arr=ARGV
else
  arr=$stdin
end  

arr.each { |argv|
  # build a 4-char string representation of IP address
  # in network byte order so it can be a string compare below
  ipstr= argv.split(".").map {|x| x.to_i.chr}.join

  # low/high water marks initialized
  low,high=0,record_max
  while true
    mid=(low+high)/2              # binary search median
    # at comparison, values are big endian, i.e. packed("N")
    if ipstr>=table[10*mid,4]     # is this IP not below the current range?
      if ipstr<=table[10*mid+4,4] # is this IP not above the current range?
        puts table[10*mid+8,2]    # a perfecct match, voila!
        break
      else
        low=mid+1                 # binary search: raise lower limit
      end
    else
      high=mid-1                  # binary search: reduce upper limit
    end
    if low>high                   # no entries left? nothing found
      puts "no country"
      break
    end
  end
}
