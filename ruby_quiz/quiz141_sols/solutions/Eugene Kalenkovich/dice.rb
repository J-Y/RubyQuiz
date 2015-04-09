require 'bigdecimal'
require 'bigdecimal/util'

def f(n) (1..n).inject(1){|a,i|a*=i} end
def comb(m,n)
  num,denum=m,1;
  (2..n).each{|i| num*=(m-i+1); denum*=i}
  num/denum
end
def fives(m,n) (0..m-n).inject(0) {|s,i| s+=5**i * comb(m,i)} end

case ARGV[0]
when '-v'
  step=1
  ARGV.shift
when '-s'
  step=50_000
  ARGV.shift
end
num=ARGV[0].to_i
min=ARGV[1].to_i

all=6**num
good=fives(num,min)

if (step)
  zipper=Array.new(num,1)
  0.step(all-1,step) do |i|
    s=i.to_s(6).tr('012345','123456').rjust(num,'1').gsub(/(\d)(?=\d)/,'\1,').reverse
    flag = (s.count('5')>=min) ? '<==' : ''
    puts "%10s [%#{num*2-1}s] %4s" % [i+1,s,flag]
  end
end

if all > Float::MAX.to_d
  prob=good.to_s.to_d/all
else
  prob=good.to_f/all
end

puts
puts "Number of desirable outcomes is #{good}"
puts "Number of possible outcomes is #{all}"
puts
puts "Probability is #{prob}"
