class Bit
 include Comparable

 def initialize(bit = false)
   if bit.respond_to? :to_i
     @bit = (bit.to_i & 1) == 1
   else
     @bit = true & bit
   end
 end

 def &(bit)
   Bit.new(@bit & Bit.new(bit).high?)
 end

 def |(bit)
   Bit.new(@bit | Bit.new(bit).high?)
 end

 def ^(bit)
   Bit.new(@bit ^ Bit.new(bit).high?)
 end

 def ~@
   Bit.new(!@bit)
 end

 def <<(int)
   Bit.new(0)
 end
 alias :>> :<<

 def <=>(bit)
   cmp = Bit.new(bit)
   if (self & cmp | ~self & ~cmp).high?
     0
   elsif (self & ~cmp).high?
     1
   else
     -1
   end
 end

 def to_s
   to_i.to_s
 end
 alias :inspect :to_s

 def to_i
   if @bit
     1
   else
     0
   end
 end

 def high?
   @bit
 end

 def low?
   !@bit
 end

 # Returns 2 bits : [result, carry]
 def add(bit, carry)
   [Bit.new(self ^ bit ^ carry), Bit.new(self & bit | self & carry |
bit & carry)]
 end
end

class DivisionByZero < StandardError; end

class UFWI
 include Comparable

 attr_reader :width

 def initialize(int=0, width=8)
   if block_given?
     @width = int
     @bits = Array.new(@width) {|index| Bit.new(yield( index)) }
   else
     @width = width
     @bits = Array.new(@width) {|bit| Bit.new(int.to_i >> bit) }
   end
 end

 def to_i
   @bits.reverse.inject(0) {|num, bit| (num << 1) + bit.to_i}
 end
 alias :to_int :to_i

 def coerce(*args)
   to_int.coerce(*args)
 end

 def to_s
   @bits.reverse.join
 end
 alias :inspect :to_s

 def to_a
   @bits.reverse
 end

 def [](index)
   if index.between? 0, width-1
     @bits[index]
   else
     Bit.new(0)
   end
 end

 def []=(index, value)
   @bits[index] = Bit.new(value)
 end

 def <=>(cint)
   cmp = self.class.new(cint, width)
   to_a <=> cmp.to_a
 end

 def &(cint)
   a = self.class.new(cint, width)
   self.class.new(width) {|bit| @bits[bit] & a[bit] }
 end

 def |(cint)
   o = self.class.new(cint, width)
   self.class.new(width) {|bit| @bits[bit] | o[bit] }
 end

 def ^(cint)
   x = self.class.new(cint, width)
   self.class.new(width) {|bit| @bits[bit] ^ x[bit] }
 end

 def ~@
   self.class.new(width) {|bit| ~@bits[bit] }
 end

 def +@
   self
 end

 def >>(int)
   self.class.new(width) {|bit| self[bit+int] }
 end

 def <<(int)
   self.class.new(width) {|bit| self[bit-int] }
 end

 def +(cint)
   added = self.class.new(cint, width)
   carry = 0
   self.class.new(width) { |bit|
     r, carry = self[bit].add(added[bit], carry)
     r
   }
 end

 def -(cint)
   sub = ~self.class.new( cint, width)+1
   self + sub
 end

 def *(cint)
   mult = self.class.new( cint, width)
   wide_self = self.class.new(self, 2 * width)
   res = self.class.new(0, 2 * width)
   width.times { |bit|
     res += wide_self << bit if mult[bit].high?
   }
   res
 end

 def / (cint)
   # Binary euclidian division

   b = self.class.new(cint, width)
   raise DivisionByZero if b == 0
   b0 = self.class.new(1, width)
   width.times {
     break if self < b0*b
     b0 <<= 1
   }
   a0 = b0 >> 1

   while b0 - a0 > 1 do
     c = (a0 >> 1) + (b0 >> 1)
     if c * b <= self
       a0 = c
     else
       b0 = c
     end
   end
   a0
 end
end

class SFWI < UFWI
 alias :unsigned_to_i :to_i
 def to_i
   if @bits.last.high?
     -((~self).unsigned_to_i + 1)
   else
     unsigned_to_i
   end
 end

 def -@
   ~self+1
 end
end
