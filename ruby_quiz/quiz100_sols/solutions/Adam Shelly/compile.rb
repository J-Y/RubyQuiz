module Compiler

 # The whole thing wrapped up into one function....
 #
 # The first half tokenizes into single chars or fixnums: it uses gsub
 # to convert '**' to '^', binary '-'' to '~', and to remove pointless '+'s.
 # Digits and most remaining '-'s are collected and converted using to_i.
 # A few pesky unary '-'s are converted to the token 'n'
 #
 # The second half uses the shunting yard algorithm to build the RPN,
 # and does the token->bytecode translation inline.
 #
 # The Tokens array contains 4 items: the character token, the bytecode,
 # and two precedence values - one for a token on the stack,
 # and another for a token in the stream. The values are only different
 # if the operator is right-associative - this simplifies the conditional
 # for deciding when to pop operators.
 # The 'n' token is expanded to [0,swap,sub]

Tokens = [['+',10,3,3],['~',11,3,3],['*',12,2,2],['/',14,2,2],['%',15,2,2],
         ['^',13,1,0],['n',[1,0,0,0xa0,11],-1,-2],[nil,'(',9,9]]

def self.compile expr
 num,tokens,output,stack='',[],[],[]

 expr.gsub(/(\d|\))-/,'\1~').gsub(/(^|[^\d)])\++/,'\1').gsub("**","^").each_byte{|b|
   if /\d|-/ =~ c=b.chr
     num+=c
     num.gsub!('--','')
   else
     tokens << (/\d/=~num ? num.to_i : 'n') and num='' unless num.empty?
     tokens << c
   end
 }
 tokens << num.to_i unless num.empty?

 tokens.each{|token|
   case token
     when Integer
       output += (-2**15...2**15)===token ?
         [1]+[token].pack('n').unpack('C*') :
         [2]+[token].pack('N').unpack('C*')
     when '('
       stack << token
    when ')'
       output << stack.pop until stack.last == '('
       stack.pop
     else
       tokdef = Tokens.assoc(token)
       output << stack.pop while t=stack.last and Tokens.rassoc(t)[2] <= tokdef[3]
       stack << tokdef[1]
   end
 }
 (output+stack.reverse).flatten
end
end
