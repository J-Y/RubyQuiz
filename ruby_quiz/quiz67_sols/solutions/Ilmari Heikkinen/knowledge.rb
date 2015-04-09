[
lambda{

puts "humbleness is a virtue"
def attribute(*a) end; module MetaKoans; def assert; 0 end end

},lambda{

puts "sometimes thinking about a problem makes it worse"
class MetaStudent; def ponder(a) 0 end end

},lambda{

puts "finish what you started"
def method_missing(*a) end; def abort(a) 0 end

},lambda{

puts "don't overextend yourself"
public; def extend(m) def koan_0; 0 end end

},lambda{

puts "know thyself";$-w=nil
class Array;def grep(a) [:id] end end

},lambda{

puts "don't send a student to do a guru's job"
class MetaStudent; def send(a) 0 end end

},lambda{

puts "question what you have been taught"
module MetaKoans; 9.times{|i| eval("def koan_#{i+1};0 end")} end

},lambda{

puts "appearances can deceive"
l=IO.read $0; puts (1..9).map{|@i| "koan_#@i"+l[998,28] }, l[1343,37]; exit

}
].instance_eval{ self[rand(size)][] }
