N  = ARGV[0].to_i
FW = (N ** 2 - 1).to_s.size + 2

def fmt(x)
  " " * (FW - x.to_s.size) + x.to_s
end

def o(n, r, c)
  x = (n - 1) ** 2
  if    c == 0      then x + r
  elsif r == n - 1  then x + r + c
  else                   e(n - 1, r, c - 1)
  end
end

def e(n, r, c)
  x = (n ** 2) - 1
  if    r == 0      then x - c
  elsif c == n - 1  then x - c - r
  else                   o(n - 1, r - 1, c)
  end
end

def spiral(n)
  (0...n).map do |r|
     if (n % 2).zero?  # even
        (0...n).map { |c| fmt(e(n, r, c)) }
     else
        (0...n).map { |c| fmt(o(n, r, c)) }
     end.join
  end.join("\n")
end

puts spiral(N)
