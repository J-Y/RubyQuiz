t={}

while t.length<(6561)

 e = Array.new(17){|i| i=i%2==0?i/2+1:["","+","-"][rand(3)]}.join

 t.store(e,eval(e))

end

t.sort.each {|a| f=a[1]==100?'*':' '; puts "#{f} #{a[0]}=#{a[1]} #{f}"}
