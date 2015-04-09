require 'delegate'

def UnsignedFWI(bits = 32)
 Class.new(DelegateClass(Bignum)) {
   define_method(:fix)       {|n| n & (1<<bits)-1 }
   define_method(:initialize){|n| super fix(n.to_i)  }
   define_method(:coerce)    {|n| [self.class.new(n),self.to_i] }
   [:+,:-,:/,:*,:%,:**,:-@,:+@,:&,:|,:^,:<<,:>>,:~].each{|m|
     define_method(m) {|*args|  self.class.new super(*args) }
   }
 }
end

def SignedFWI(bits = 32)
 Class.new(UnsignedFWI(bits)) {
   define_method(:fix){|n| (n & (1<<bits)-1) - (n[bits-1] << bits) }
 }
end
