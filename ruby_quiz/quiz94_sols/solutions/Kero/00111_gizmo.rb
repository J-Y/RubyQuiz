# Author: Kero van Gelder
# Copyright: Kero van Gelder, can be distributed under LGPL

require 'stringio'

module SecretAgent00111CommunicationGizmo

  class UndefinedRLE < RuntimeError
  end

  def self.unrle(ary)
    ary.inject([]) {|un, val|
      un.concat([true] * val)
      un << false
    }
  end

  def self.rle(ary)
    result = []
    while not ary.empty?
      nr = 0
      while not ary.empty? and ary[0]
        nr += 1
        ary.shift
      end
      raise UndefinedRLE  if ary.empty?
      ary.shift
      result << nr
    end
    raise UndefinedRLE  if result.empty?
    result
  end

  Log2 = Math.log(2)

  def self.encode(ary, exponent)
    io = StringIO.new
    encoder = Encoder.new(exponent, io)
    ary.each{|result| encoder << result}
    encoder.finish
    io.string
  end

  def self.decode(bitstring)
    ary = Decoder.new(StringIO.new(bitstring)).read
    ary.pop
    ary
  end

  class Encoder
    attr_reader :exponent, :io

    def initialize(exponent, io)
      @exponent, @io = exponent, io
      io.print [exponent].pack("c")
      @ones = 0
      @buf = ""
      # @finished = false
    end

    def << bool
      finished? and raise "Channel closed"
      if bool
        @ones += 1
      else
        m = 2**exponent
        div, rem = @ones.divmod m
        @buf << ("1" * div)
        @buf << (("%0#{exponent+1}s" % (rem).to_s(2)).gsub(/ /, "0"))
        if (blen = @buf.length) >= 8
          #p [exponent, div, rem, @buf, blen]
          bytes = blen / 8
          io.print([@buf.slice!(0, bytes * 8)].pack("B*"))
        end
        #p io.string
        @ones = 0
      end
    end

    def finish
      self << false
      @finished = true
      @buf << ("1" * (8 - @buf.length % 8))  if @buf.length % 8 > 0
      io.print([@buf].pack("B*"))
    end

    def finished?
      @finished
    end
  end

  class Decoder
    attr_reader :io
    def initialize(io)
      @io = io
      @state = :exp
      @buf = ""
      @div = 0
      @rem = ""
    end

    def exponent
      if @state == :exp # and io.ready?
        @exponent = io.read(1).unpack("c")[0]
        @state = :div
      end
      @exponent
    end

    def read
      if @state == :exp # and io.ready?
        @exponent = io.read(1).unpack("c")[0]
        @state = :div
      end
      result = []
      @buf << io.read.unpack("B*")[0]
      while not @buf.empty?
        #p [@buf, @state, @exponent, @div, @rem]

        if @state == :div
          while not @buf.empty? and @buf[0] == ?1
            @buf.slice!(0, 1)
            @div += 1
          end
          @state = :rem  unless @buf.empty?
        end
        #p [@buf, @state, @div, @rem]

        if @state == :rem
          req = exponent + 1 - @rem.length
          if @buf.length < req
            @rem << @buf.slice!(0..-1)
          else
            @rem << @buf.slice!(0, req)
            result.concat([true] * (@div * 2**exponent + @rem.to_i(2)))
            result << false
            @div = 0
            @rem = ""
            @state = :div
          end
        end
      end
      result
    end

  end
end
