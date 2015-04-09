t={}

while t.length<(6561)

 t.store(Array.new(17){|i| i=i%2==0?i/2+1:["","+","-"][rand(3)]}.join,'')

end

t.sort.each {|a| f=eval(a[0])==100?'*':' '; puts "#{f}
#{a[0]}=#{eval(a[0])} #{f}"}
