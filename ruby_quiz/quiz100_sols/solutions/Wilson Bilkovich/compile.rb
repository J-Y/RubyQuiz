class Compiler
 def self.compile(input)
   @bytecodes ||= {'+' => 0x0a, '-' => 0x0b, '*' => 0x0c, '**' => 0x0d, '/' => 0x0e, '%' => 0x0f}
   encode postfix(input)
 end

 def self.encode(tokens)
   tokens.collect do |token|
     number = token =~ /\-?\d+/ ? token.to_i : nil
     if (-32768..32767).include?(number)
       [0x01] + [number].pack('n').unpack('C*')
     elsif !number.nil? # long
       [0x02] + [number].pack('N').unpack('C*')
     else
       @bytecodes[token]
     end
   end.flatten
 end

 def self.postfix(infix)
   stack, stream, last = [], [], nil
   tokens = infix.scan(/\d+|\*\*|[-+*\/()%]/)
   tokens.each_with_index do |token,i|
     case token
     when /\d+/; stream << token
     when *@bytecodes.keys
       if token == '-' and last.nil? || (last =~ /\D/ && tokens[i+1] =~ /\d/)
         tokens[i+1] = "-#{tokens[i+1]}"
       else
         stream << stack.pop while stack.any? && preceded?(stack.last, token)
         stack << token
       end
     when '('; stack << token
     when ')'; (stream += stack.slice!(stack.rindex('('), stack.size).reverse).pop
     end
     last = token
   end
   stream += stack.reverse
 end

 def self.preceded?(last, current)
   @ops ||= {'+' => 1, '-' => 1, '%' => 2, '/' => 2, '*' => 2, '**' => 3, '(' => 0, ')' => 0}
   @ops[last] >= @ops[current] && current != '**' # right associative mayhem!
 end
end
