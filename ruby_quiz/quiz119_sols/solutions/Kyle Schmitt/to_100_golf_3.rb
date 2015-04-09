t=Array.new(6561){|i|i}

t.each_index{|a| while t[a]=Array.new(17){|i|
i=i%2==0?i/2+1:["","+","-"][rand(3)]}.join and not
t.length==t.uniq.length;end}

t.sort.each {|a| f=eval(a)==100?'*':' '; puts "#{f} #{a}=#{eval(a)} #{f}"}

