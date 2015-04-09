n = ARGV[0].to_i

def pascal_line(n)
  x = 1
  (1..n).inject([]) do |a,i| a << x; x = x * (n-i)/i; a end
end
def pascal_max(n)
  (1..n/2).inject(1) do |x,i| x = x * (n-i)/i end
end
def print_with_spaces(n, max)
  len = n.to_s.length
  diff = (max.to_f-len.to_f)/2
  print " " * (diff - 0.1).round, n, " " * (diff).round
end

spaces = pascal_max(n).to_s.length

(1..n).each do |i|
  print " " * (spaces * (n-i)-1 / 2)
  pascal_line(i).each do |j| print_with_spaces j, spaces; print " " * spaces end
  print "\r\n"
end
