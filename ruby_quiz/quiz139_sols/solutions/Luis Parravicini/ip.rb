require 'readbytes'

# reads the ip range for the record at position pos
def read_ips(f, pos)
  f.pos = pos * 10
  buf = f.readbytes(8)
  [ buf[0, 4], buf[4, 8] ].map { |b| b.unpack('N')[0] }
end

# gets the country for the record at position pos
def get_country(f, pos)
  f.pos = pos * 10 + 8
  f.readbytes(2)
end

# binary search of the ip (based on the binary search at
# http://eigenclass.org/hiki.rb?simple+full+text+search+engine#l20 )
def binary_search(f, ip, from, to)
  while from < to
    middle = (from + to) / 2
    pivot = read_ips(f, middle)

    if ip < pivot[0]
      to = middle
      next
    elsif ip > pivot[1]
      from = middle+1
      next
    end

    if ip >= pivot[0] && ip <= pivot[1]
      return get_country(f, middle)
    else
      return nil
    end
  end
end

# converts the ip in a.b.c.d form to network order
def to_network(ip)
  aux = ip.split('.').map { |x| x.to_i }

  aux[3] + (aux[2] << 8) + (aux[1] << 16) + (aux[0] << 24)
end


ip = ARGV[0]
if ip.nil?
  puts "usage: #{__FILE__} ip_address"
  exit 1
end
ip = to_network(ip)

File.open('ip_country', 'r') do |f|
  f.seek(0, IO::SEEK_END)
  records = f.tell / 10

  country = binary_search(f, ip, 0, records)
  country = 'not found' if country.nil?
  puts country
end
