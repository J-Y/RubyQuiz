DIM = ARGV[0].to_i
FLD = (DIM ** 2 - 1).to_s.size + 2

def fmt(x)
	" " * (FLD - x.to_s.size) + x.to_s
end

def orow(n, i)
	m = n ** 2
	x = m - n

	if i == n - 1
		(1..n).inject("") { |o, v| o + fmt(m - v) }
	else
		erow(n - 1, i) + fmt(x - n + i + 1)
	end
end

def erow(n, i)
	m = n ** 2
	x = m - n

	if i == 0
		(0...n).inject("") { |o, v| o + fmt(x + v) }
	else
		fmt(x - i) + orow(n - 1, i - 1)
	end
end


def spiral(n)
	if (n % 2).zero?
		n.times { |i| puts erow(n, i) }
	else
		n.times { |i| puts orow(n, i) }
	end
end

spiral(ARGV[0].to_i)
