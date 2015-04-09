class Integer
  def c_modulo(o)
    if ((self >= 0 and o >= 0) or (self <=0 and o < 0))
      return self % o
    else
      return 0 if (self % o) == 0
      return (self % o) - o
    end
  end
  def c_div(o)
    return((self - self.c_modulo(o))/o);
  end
end

class FWI
  class FWIBase
    attr_reader :rawval
    include Comparable
    @@carry = 0
    def initialize(n)
      @rawval = n.to_i & maskval
      @@carry = (n.to_i != to_i) ? 1 : 0
    end
    def FWIBase.carry; @@carry; end
    def FWIBase.carry?; @@carry==1; end
    def maskval; 0xF; end
    def nbits; 4; end
    def signed?; false; end
    def to_i; rawval; end
    def to_s; to_i.to_s; end
    #def inspect; "<0x%0#{(nbits/4.0).ceil}x;%d>" % [rawval,to_i]; end
    def inspect; to_s; end
    def hash; to_i.hash; end
    def coerce(o)
      return self.class.fwi_coerce(o,self) if o.is_a? Integer
      to_i.coerce(o)
    end
    def ==(o)
      if (o.is_a? FWIBase) then 
        to_i == o.to_i
      else
        to_i == o
      end
    end
    def eql?(o)
      o.class == self.class and self == o
    end
    def FWIBase.set_coerce_method(meth)
      case meth
      when :kr
        class << self
          def fwi_coerce(a,b)
            c = FWI.kr_math_class(a,b)
            [c.new(a),c.new(b)]
          end
        end
      when :ansi
        class << self
          def fwi_coerce(a,b)
            c = FWI.ansi_math_class(a,b)
            [c.new(a),c.new(b)]
          end
        end
      when :first
        class << self
          def fwi_coerce(a,b)
            return [a,b.to_i] if a.is_a? Integer
            [a,a.class.new(b)]
          end
        end
      when :second
        class << self
          def fwi_coerce(a,b)
            return [a.to_i,b] if b.is_a? Integer
            [b.class.new(a),b]
          end
        end
      else
        class << self
          self.send(:undef_method,:fwi_coerce)
        end
      end
    end
    %w(+ - / * ^ & | ** % << >> c_div c_modulo div modulo).each { |op|
      ops = op.to_sym
      FWIBase.send(:define_method,ops) { |o|
        if (o.class == self.class) 
          self.class.new(to_i.send(ops,o.to_i))
        elsif o.is_a? Integer or o.is_a? FWIBase then
          b = self.class.fwi_coerce(self,o)
          b[0].send(ops,b[1])
        else
          to_i.send(ops,o)
        end
      }
    }
    %w(-@ +@ ~).each { |op|
      ops = op.to_sym
      FWIBase.send(:define_method,ops) { 
        self.class.new(to_i.send(ops))
      }
    }
    def <=>(o)
      to_i.<=>(o)
    end
    # And now add a few x86 assembly operations
    # I only bother with rcl here, but for completeness
    # one could easily implement rcr, rol, ror, adc, sbb, etc.
    def rcl(n=1)
      lbits = n % (nbits+1)
      big = @rawval << lbits
      big |= (FWIBase.carry << (lbits-1))
      self.class.new((big & (2*maskval+1)) | (big >> (nbits+1)))
    end
    def rcl!(n)
      @rawval = maskval && rcl(n).to_i
    end
    def FWIBase.c_math(a, op, b)
      op = :c_div if op == :/
      op = :c_modulo if op == :%
      a,b = self.fwi_coerce(a,b)
      self.new(a.send(op,b))
    end
  end

  @@clazzhash = Hash.new {|h,k|
    l1 = __LINE__
    FWI.class_eval(%Q[
    class FWI_#{k} < FWI::FWIBase
      def initialize(n); super(n); end
      def maskval; #{(1<<k) - 1};end
      def signed?; false; end
      def nbits; #{k}; end
    end
    class FWI_#{k}_S < FWI_#{k}
      def signed?; true; end
      def to_i
        if rawval < #{1<<(k-1)} then
          rawval
        else
          rawval - #{1<<k}
        end
      end
    end
    ], __FILE__, l1+1)
    h[k] = FWI.class_eval(%Q"[FWI_#{k},FWI_#{k}_S]",
                __FILE__, __LINE__ - 1)
  }
  def FWI.new(n,signed=true)
    @@clazzhash[n][signed ? 1 : 0]
  end
  # K&R-like
  # First, promote both to the larger size.
  # Promotions of smaller to larger preserve unsignedness
  # Once promotions are done, result is unsigned if
  # either input is unsigned
  def FWI.kr_math_class(a,b)
    return b.class if (a.is_a? Integer)
    return a.class if (b.is_a? Integer)
    nbits = a.nbits
    nbits = b.nbits if b.nbits > nbits
    signed = a.signed? && b.signed?
    FWI.new(nbits,signed)
  end
  # ANSI C-like
  # promotions of smaller to larger promote to signed
  def FWI.ansi_math_class(a,b)
    return b.class if (a.is_a? Integer)
    return a.class if (b.is_a? Integer)
    nbits = a.nbits
    nbits = b.nbits if b.nbits > nbits
    signed = true
    signed &&= a.signed? if (a.nbits == nbits)
    signed &&= b.signed? if (b.nbits == nbits)
    FWI.new(nbits,signed)
  end
  FWIBase.set_coerce_method(:ansi)
end

# support the syntax from the quiz spec
class UnsignedFixedWidthInt
  def UnsignedFixedWidthInt.new(width,val)
    FWI.new(width,false).new(val)
  end
end
class SignedFixedWidthInt
  def SignedFixedWidthInt.new(width,val)
    FWI.new(width,true).new(val)
  end
end

# support the syntax in Sander Land's test case
def UnsignedFWI(width)
  FWI.new(width,false)
end

def SignedFWI(width)
  FWI.new(width,true)
end

__END__
