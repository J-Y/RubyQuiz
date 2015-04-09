class Integer
  def fact
     zero? ? 1 : (1..self).inject { |m, o| m * o }
  end

  def binom(k)
     self.fact / (k.fact * (self - k).fact)
  end
end

def pascal n
  # calc field width
  width = (n - 1).binom(n / 2).to_s.length

  # keep only one row in memory
  row = [1]

  1.upto(n) do |i|
     # print row
     space = ' ' * width * (n-i)
     puts space + row.collect { |x| x.to_s.center(2*width) }.join

     # generate next row
     row = row.inject([0]) { |m, o| m[0...-1] << (m[-1] + o) << o }
  end
end

pascal (ARGV[0] || 10).to_i
