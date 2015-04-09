File.open('ip_country', 'w') do |out|
  File.open('IpToCountry.csv', 'r') do |csv|
    while line = csv.gets do
      next unless line =~ /^"(\d+)","(\d+)"(?:,"[^"]+"){2},"([A-Z]+)"/

      out.write([$1.to_i].pack('N'))    # from
      out.write([$2.to_i].pack('N'))    # to
      out.write($3[0,2])                    # country
    end
  end
end
