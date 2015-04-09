require 'ftools'

ip = ARGV[0].split(/\./)
ip = ip[0].to_i * 16777216 + ip[1].to_i * 65536 + ip[2].to_i * 256 + ip[3].to_i
file = ARGV[1] || 'ipdb.csv'

File.open(file) do |f|
  low = 0
  high = f.stat.size
  f.seek(high / 2)
  while low < high
    while (((a = f.getc) != 10) && (f.pos > 2))
        f.seek(-2, IO::SEEK_CUR)
    end
    pos = f.pos
    line = f.readline.split(",")
    low_range = line[0][1..-2].to_i
    high_range = line[1][1..-2].to_i
    if (low_range > ip)
      high = pos
      offset = (f.pos - pos) + ((high - low) / 2)
      f.seek(-offset, IO::SEEK_CUR)
    elsif (high_range < ip)
      low = f.pos
      f.seek((high-low) / 2, IO::SEEK_CUR)
    else
      puts line[4][1..-2]
      exit
    end
  end
  puts "No country found"
end
