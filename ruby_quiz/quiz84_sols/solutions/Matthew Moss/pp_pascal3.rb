$fact = Hash.new do |h, n|
  # The extra multiply allows us to use higher n before overflowing the stack.
  h[n] = (n < 2) ? 1 : n * (n - 1) * h[n - 2]
end

def binom(n, k)
  $fact[n] / ($fact[k] * $fact[n - k])
end

def pascal n
  fw = binom(n - 1, n / 2).to_s.length     # field width
  rw = (n * 2) * fw                        # row width

  (0...n).each do |i|        # generate and print each row
     puts((0..i).map { |x| binom(i, x).to_s.center(2 * fw) }.join.center(rw))
  end
end

pascal (ARGV[0] || 10).to_i
