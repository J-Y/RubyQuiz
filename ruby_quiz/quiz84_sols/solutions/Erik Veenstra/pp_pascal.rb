class CachedLambda < Struct.new(:block, :cache)
  def initialize(*args)
    super
    @caller = caller
    at_exit do
      $stderr.puts [@caller, cache.size].inspect
    end
  end

  def [] *args
    cache[args] ||= block.call(*args)
  end
end

def c_lambda &b
  CachedLambda.new b, {}
end

fac = c_lambda{|n| n < 2 ? 1 : (1..n).inject{|f, i| f * i}}
tri = c_lambda{|n, r| fac[n] / (fac[r] * fac[n-r])}
size = c_lambda{|r| tri[r-1, r / 2].to_s.size + 1}
line = c_lambda{|y, r| (0..y).map{|x| tri[y,x].to_s.center size[r]}}
lines = c_lambda{|r| (0...r).map{|y| line[y, r]}}
pascal = c_lambda{|r| lines[r].map{|l| l.join.center(size[r]*r).rstrip}}

puts pascal[(ARGV[0] || 15).to_i]
