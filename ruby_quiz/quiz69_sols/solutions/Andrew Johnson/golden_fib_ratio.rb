#!/usr/bin/ruby -w

Fib = Hash.new{|h,n|n<2?h[n]=n:h[n]=h[n-1]+h[n-2]}

def fibicle(n,dia=[])
  return dia if n == 0
  cols, rows = Fib[n+1], Fib[n]
  cols, rows = rows, cols if n%2 != 0
  cols *= 2
  (0..rows).each{dia << [" "]*cols} if dia.empty?
  (0..cols).each{|i|dia[0][i]    = i%2!=0?"_":" "}    # top
  (0..cols).each{|i|dia[rows][i] = i%2!=0?"_":" "}    # bottom
  dia[1..rows].each{|row| row[0],row[cols] = "|","|"} # sides
  fibicle(n-1,dia)
end

fibicle(ARGV[0].to_i).each{|r|puts r.join}

__END__
