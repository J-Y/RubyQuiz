require 'faster_csv'
ip = ARGV[0].split(/\./)
ip = ip[0].to_i * 16777216 + ip[1].to_i * 65536 + ip[2].to_i * 256 + ip[3].to_i
file = ARGV[1] || 'ipdb.csv'

FasterCSV.foreach(file) do |line|
  if (line[0].to_i <= ip && line[1].to_i >= ip)
    puts line[4]
    exit
  end
end
