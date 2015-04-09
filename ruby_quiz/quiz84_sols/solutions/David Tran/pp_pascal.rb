require 'enumerator'

def pascal(row_count)
 result = [[1]]
 (row_count - 1).times do
   new_row = [1]
   result.last.each_cons(2) { |a| new_row << (a[0] + a[1]) }
   result << (new_row << 1)
 end
 result
end

def pp_pascal(rows)
 max_digits = rows.last[rows.last.size / 2].to_s.size
 lines = rows.map {|row| row.map { |e| "%#{max_digits}i" % e }.join(' ') }
 max_size = lines.last.size
 lines.each { |line| puts line.center(max_size) }
end

pp_pascal(pascal((ARGV[0] || 10).to_i))

