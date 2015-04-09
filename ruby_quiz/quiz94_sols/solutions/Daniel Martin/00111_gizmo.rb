#! /usr/bin/env ruby
require 'io/nonblock'

# The SecretAgent00111CommunicationGizmo class implements a way to
# send a series of true/false values through a binary channel using
# only a relatively small number of bytes.  It does this by assuming
# that true values are much more likely than false values, and
# that therefore one can do a simple run length encoding on the
# original series of true/false values and end up with a sequence
# of numbers amenable to being compressed by a Rice code. (i.e. by
# a Golomb code with the parameter a power of 2)
#
# The format of a compressed message of integers is:
#
# * One byte of _exponent_.  Our code will use a parameter value of 
#   b = 2 ** _exponent_
# * For each number _n_ that's encoded:
#   * _d_ '1' bits
#   * a '0' bit
#   * _exponent_ bits that as a binary number form the value _r_
#   The number _n_ then has the value <tt> n == d * (2 ** exponent) + r </tt>
# * Whatever number of '1' bits are necessary to pad the whole
#   transmission to an even byte boundary
#
# Bits within a byte are ordered as by _pack("B*")_ -- that is, MSB first.
class SecretAgent00111CommunicationGizmo
  class UndefinedRLE < Exception; end
end

# We're going to define a bunch of class methods now,
# and SecretAgent00111CommunicationGizmo is just too
# long to write out over and over again, and I don't
# like the look of putting "self." in front of each
# method name as I define it, so...
class << SecretAgent00111CommunicationGizmo

  # Run length encode an input array of true/false values.
  # Note that this array *must* end in a "false" value, or an
  # exception (SecretAgent00111CommunicationGizmo::UndefinedRLE)
  # will be thrown.
  def rle(tfarr)
    raise self::UndefinedRLE unless false == tfarr.last
    ans = []
    tfarr.inject(0) {|a,tf|
      if tf
        a + 1
      else
        ans<<a; 0
      end
    }
    ans
  end

  # Undo the operation of +rle+.  Expands a given array of numbers
  # into an array of true/false values.
  def unrle(inarr)
    inarr.map{|x| [[true]*x,false]}.flatten
  end

  # This method does the internal work of encoding a
  # given number by our Rice code into a string of '0' and '1'.
  # Not really for client use.
  def bits_for_encoding(x, exponent)
    a, b = x.divmod(1<<exponent)
    ['1' * a, sprintf('0%0*b', exponent, b)].join
  end

  # Encode a true/false array by first adding a "false" to the end
  # and then encoding the resulting string of numbers via our Rice
  # code.
  def encode(array,exponent)
    msg = rle(array+[false]).map{|x|
      bits_for_encoding(x,exponent)
    }.join
    msg += '1' * ((- msg.length) % 8)
    exponent.chr + [msg].pack("B*")
  end

  # This method does the internal work to decode a
  # message in '1' and '0' bits into an array of
  # integers.  Note that the string in msg is changed
  # by this method, and shortened to whatever sequence
  # at the end couldn't be decoded.
  def decode_bits(msg,exponent)
    ans = []
    trim_from = 0
    msg.scan(/(1*)0([01]{#{exponent}})/) {|a,b|
      ans << a.length*(1<<exponent) + b.to_i(2)
      trim_from = $~.end(0)
    }
    msg.slice!(0,trim_from)
    ans
  end

  # Undo the result of +encode+
  def decode(bitstring)
    # It's not polite to mangle someone else's bitstring
    # so don't use slice! here
    # Seriously, the sample program stops working if you
    # mangle bitstring because then it doesn't give the right
    # input to Decoder.new(StringIO.new(s))
    exponent = bitstring.slice(0,1)[0]
    msg = bitstring[1..-1].unpack("B*")[0]
    unrle(decode_bits(msg,exponent))[0..-2]
  end
end

class SecretAgent00111CommunicationGizmo
  # Lets subclasses call class methods as their own
  def method_missing(meth, *args)
    self.class.send(meth,*args)
  end

  # This class is meant for on-the-fly compression to a given
  # IO channel.
  class Encoder < SecretAgent00111CommunicationGizmo
    def initialize(exponent, output)
      output << exponent.chr
      @exponent = exponent
      @output = output
      @current_byte = ''
      @current_run = 0
    end
    def <<(tf)
      if tf
        @current_run += 1
      else
        send_number(@current_run)
        @current_run=0
      end
      self
    end
    def finish
      self << false
      @current_byte += '1' * ((-@current_byte.length)%8)
      output_maybe
    end

    private
    def output_maybe
      if @current_byte.length >= 8
        out_bits = @current_byte.slice!(0,(@current_byte.length/8)*8)
        @output << [out_bits].pack("B*")
      end
    end
    def send_number(x)
      @current_byte += bits_for_encoding(x,@exponent)
      output_maybe
    end
  end

  # This class is meant for on-the-fly decompression to a given
  # IO channel.
  class Decoder < SecretAgent00111CommunicationGizmo
    attr_reader :exponent
    def initialize(io)
      # StringIO isn't really an IO object, so doesn't know about
      # nonblock.
      io.nonblock = true if io.respond_to?(:nonblock=)
      @io = io
      @initialized = false
      @remaining = ''
    end
    def exponent
      if not @initialized
        @exponent = @io.readchar
        @initialized = true
      end
      @exponent
    end
    def read
      exp = exponent
      ans = []
      # Use read with no arguments since read with an integer
      # argument messes up the bizarre way StringIO is used in
      # the unit test.  Does Q not know about IO.pipe ?
      buff = @io.read rescue buff = nil
      while buff and buff.length > 0
        @remaining += buff.unpack("B*")[0]
        ans.concat unrle(decode_bits(@remaining, exp))
        buff = @io.read rescue buff = nil
      end
      ans
    end
  end
end
