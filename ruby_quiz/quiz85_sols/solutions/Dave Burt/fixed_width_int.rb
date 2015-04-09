#
# C-Style Ints
#
# A response to Ruby Quiz #85 [ruby-talk:199723]
#
# FixedWidthInt is the parent class of an arbitrary set of c-style integer
# classes. These subclasses are accessed like so:
#
#   UInt32 = FixedWidthInt.type(:unsigned, 32)
#
# These classes will give up instances like so:
#
#   n = UInt32.get(42)  #=> #<UInt32 42>
#
# Alternatively, you can convert from other Numeric types:
#
#   x = 255.to_fixed_width_int(:unsigned, 32)  #=> #<UInt32 255>
#
# Overflows are ignored.
#
# Author: dave at burt.id.au
# Created: 2 Jul 2006
# Last modified: 3 Jul 2006
#

require 'weak_hash'

class FixedWidthInt < Numeric

  DEFAULT_SIGNED = :signed
  DEFAULT_SIZE = 31

  attr_accessor :value
  alias_method :to_int, :value
  alias_method :to_i, :value

  def initialize
    raise TypeError, "Can't instantiate abstract base class #{self.class}"
  end

  class << self

    def type(signed = DEFAULT_SIGNED, size = DEFAULT_SIZE)

      signed = case signed
               when :signed, true: true
               when :unsigned, false: false
               else raise ArgumentException,
                          "expected :signed, :unsigned, true or false"
               end

      size = size.to_int
      raise RangeError, "size must be greater than zero" if size <= 0

      @types ||= {}
      @types[[signed, size]] ||= Class.new(self) do

        @signed, @size = signed, size

        def initialize(value)

          # truncate excess bits using a mask
          @value = value & ((1 << self.class.size) - 1)

          # a signed whose high bit is set is negative
          if self.class.signed? && @value >= (1 << (self.class.size - 1))
            @value -= (1 << self.class.size) 
          end
        end

        class << self  # class methods of FixedWidthInt's subclasses

          def signed?() @signed end
          def size() @size end

          def get(value = 0)
            @instances ||= WeakHash.new
            @instances[value] ||= new(value)
          end

          def inspect
            if !name || name.empty?
              "#<#{superclass.name} #{signedness} #{size}-bit>"
            else
              name
            end
          end

          private
            def signedness
              signed? ? 'signed' : 'unsigned'
            end
        end
      end
    end

    private :new
    def get(signed = DEFAULT_SIGNED, size = DEFAULT_SIZE, value = 0)
      FixedWidthInt.type(signed, size).get(value)
    end
  end

  def coerce(other)
    [self.class.get(other), self]
  end

  def inspect
    "#<#{self.class.inspect} #@value>"
  end
  def to_s
    @value.to_s
  end

  def ==(other)
    other == to_i
  end
  def <=>(other)
    other <=> to_i
  end

  # delegate instance methods to underlying integer value
  def method_missing(meth, *args)
    unless @value.respond_to? meth
      raise NameError, "undefined method `#{meth}' for #{self}:#{self.class}"
    end
    result = @value.send(meth, *args.map {|arg|
      arg.class == self.class ? arg.to_i : arg })
    case result
    when Integer
      self.class.get(result)
    when Enumerable # e.g. divmod
      result.map do |element|
        element.kind_of?(Integer) ? self.class.get(element) : element
      end
    else
      result
    end
  end
end

class Numeric
  def to_fixed_width_int(signed = FixedWidthInt::DEFAULT_SIGNED,
                         size = FixedWidthInt::DEFAULT_SIZE)
    FixedWidthInt.type(signed, size).get(to_i)
  end
end

# bonus modules for compatibility with examples in the quiz
module SignedFixedWidthInt
  def self.new(value, size)
    FixedWidthInt.type(:signed, size).get(value).extend(self)
  end
end
module UnsignedFixedWidthInt
  def self.new(value, size)
    FixedWidthInt.type(:unsigned, size).get(value).extend(self)
  end
end
# and a couple more classes to suit Sander Land's test cases
SignedFWI = SignedFixedWidthInt
UnsignedFWI = UnsignedFixedWidthInt

if $0 == __FILE__

  UInt32 = FixedWidthInt.type(:unsigned, 32)  # define a new integer type
  i = UInt32.get(42)                          # get instance of the type
  i == 42 #=> true

  j = FixedWidthInt.get(:unsigned, 32, 86)  # no explicit type used in the call
  j.kind_of? UInt32 #=> true                # but the result's type is the same

  k = UnsignedFixedWidthInt.new(0xFF00FF00, 32) # quiz compatible syntax
  k.kind_of? UnsignedFixedWidthInt #=> true
  k.kind_of? UInt32 #=> true

end
