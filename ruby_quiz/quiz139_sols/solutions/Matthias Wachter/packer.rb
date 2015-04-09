#!/usr/bin/ruby
# comment

last_start=nil
last_end=nil
last_country=nil
File.open("packed-ip.dat","wb") do |wfile|
  IO.foreach("geo-ip.csv") do |line|
    next if !(line =~ /^"/ )
      s,e,d1,d2,co=line.delete!("\"").split(",")
      s,e = s.to_i,e.to_i
      if !last_start
# initialize with first entry
        last_start,last_end,last_country = s,e,co
      else
        if s==last_end+1 and co==last_country
# squeeze if successive ranges have zero gap
          last_end=e
        else
# append last entry, remember new one
          wfile << [last_start,last_end,last_country].pack("NNa2")
          last_start,last_end,last_country = s,e,co
        end
      end
  end
# print last entry
  if last_start
    wfile << [last_start,last_end,last_country].pack("NNa2")
  end
end
