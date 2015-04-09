require 'enumerator'

pascal = [{0, 1}] + (1...ARGV[0].to_i).map{Hash.new(0)}

pascal.each_cons(2) do |last, this|
  last.each{|p, v| this[p - 1] += v; this[p + 1] += v}
end

size = pascal.last.fetch(0, pascal.last[1]).to_s.size + 1

pascal.each do |row|
  line = row.sort.map{|p, v| v.to_s.center size}.join
  puts line.center(size * pascal.last.size).rstrip
end
