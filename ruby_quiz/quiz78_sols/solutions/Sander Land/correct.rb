def valid_packaging?(str)
 other_br = {'}'=>'{',']'=>'[',')'=>'('}
 stack = []
 pc = nil
 str.split('').each {|c|
   if other_br.values.include? c
     stack << c
	elsif mb = other_br[c]
     return false unless stack.pop == mb && pc != mb # unbalanced, or {} detected
   end
   pc = c
 }
 return stack.empty?
end

input = ARGV[0].to_s
pos = [input] + "[](){}".split('').map{|c|
 (0..input.length).map {|i| input[0...i] + c + input[i..-1] }
}

if corr = pos.flatten.find{|str| valid_packaging? str}
 puts corr
else
 exit! 1
end
