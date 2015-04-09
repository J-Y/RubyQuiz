#!/usr/bin/ruby

os = ARGV[0].split(/\./)
ip = os[3].to_i + os[2].to_i*256 + os[1].to_i*256**2 + os[0].to_i*256**3

f = File.open("IpToCountry.csv")

# perform binary search on the file
low = 0
high = f.stat.size

while low < high
  mid = (low + high) / 2

  f.seek mid  # seek to the middle of our search window
  f.seek -2, IO::SEEK_CUR  until f.getc == ?\n  # walk backwards until we hit a newline

  new_high = f.pos - 1
  line = f.gets
  new_low = f.pos

  from, to, x, x, country = line[1..-1].split(/","/)

  if to.to_i < ip  # we are too low, set new low to after this line
    low = new_low
  elsif from.to_i > ip  # we are too high, set new high to before the last newline
    high = new_high
  else
    puts country; exit
  end
end

puts "no country"