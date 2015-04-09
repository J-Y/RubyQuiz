class Integer
 # Much easier than properly parsing a string for Exper.new(???)
 # If I *really* wanted to avoid monkey-patching, I could define
 # Expr#-@ and expr#+@ instead.
 def to_expr
   Compiler::Expr.new self
 end
end

module Compiler
 CONST  = 2**15
 LCONST = 2**31

 def Compiler.compile input
   # I initially tried Expr.new(\1), but this way lets me use Ruby's
   # sign-parsing.
   m = input. gsub /(\d+)(\D*)/, '\1.to_expr()\2'
   exp = eval m
   exp.compile
 end

 # The meat of this module...
 # Rather than do any parsing, I'm just converting all the expression's numbers
 # into Expr objects, whose +-/*, etc. methods (all method_missing) just build
 # a parse-tree when I run eval.
 class Expr
   attr_reader :val

   OPERATORS = { :+ => 0x0a,
               :- => 0x0b,
               :* => 0x0c,
               :** => 0x0d,
               :/ => 0x0e,
               :% => 0x0f,
               :swap => 0xa0 } # Swap doesn't have an operator, but whatever.

   def initialize *v
     @val = v
   end

   # Take care of all those operators
   def method_missing sym, *args
     if OPERATORS.include? sym
       Expr.new [val, args.first, sym]
     else
       raise "Unknown operator: #{sym}, #{args.inspect}"
     end
   end

   def to_s
     "Expr: <#{flatten.join ' '}>"
   end

   def flatten
     # Flatten the array as much as we can, then tackle any Expr objects.
     # Finally, make sure the result is also flat
     # (because the map turns each Expr into an array)
     val.flatten.map do |i|
       if i.respond_to? :flatten
         i.flatten
       else
         i
       end
     end.flatten
   end

   def compile
     # Get a flat copy of our value, then encode each number and symbol.
     # Finally, flatten all the encoded numbers into our answer.
     arr = flatten
     arr.map do |i|
       if i.is_a? Integer
         bytes_for(i)
       elsif OPERATORS.include? i
         OPERATORS[i]
       else
         # What's the preferred method of dealing with this?
         # I could raise a different exception, or attempt to call the same
         # method in my superclass...
         raise "Unknown operator: #{i.inspect}, #{i.class}"
       end
     end.flatten
   end

   # Convert a number to bytes
   def bytes_for number
     type = size = 0
     values = []
     if number < CONST and number >= -CONST
       type, size = 1, 2
     elsif number < LCONST and number >= -LCONST
       type, size = 2, 4
     else
       raise "#{number} is too big to encode!"
     end

     size.times do |s|
       number, byte = number.divmod 256
       # I could use << here, but then I'd need to reverse values.
       values.unshift byte
     end
     [type, *values]
   end

 end #expr

end #Compiler
