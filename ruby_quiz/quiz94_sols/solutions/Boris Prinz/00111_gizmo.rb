require 'stringio'

module SecretAgent00111CommunicationGizmo
  class ExponentUndefined < Exception
  end

  class UndefinedRLE < Exception
  end

  def self.decode data
    events = Decoder.new(StringIO.new(data)).read
    events.pop # remove last false
    events
  end

  def self.encode events, exponent
    io = StringIO.new
    e = Encoder.new(exponent, io)
    events.each do |result|
      e << result
    end
    e.finish
    io.string
  end

  def self.rle events
    raise UndefinedRLE.new if events.size == 0
    rl = []
    truevals = 0
    events.each do |result|
      if result
        truevals += 1
      else
        rl << truevals
        truevals = 0
      end
    end
    raise UndefinedRLE.new if truevals != 0
    rl
  end

  def self.unrle rl
    events = []
    rl.each {|n| events += [true]*n + [false]}
    events
  end

  class Encoder
    def initialize exponent, io
      @exponent = exponent
      @io = io
      @events = []
      @bits = ''
      @io << exponent.chr
    end

    def << result
      @events << result
      if result == false
        encode_events
      end
    end

    def encode_events
      n = @events.size - 1
      @events = []
      @bits << "1" * (n / 2**@exponent)
      @bits << "%0#{@exponent+1}B" % (n % 2**@exponent)
      flush_bytes
    end

    def flush_bytes
      # write every 8 bits to the stream:
      @bits.gsub!(/[01]{8}/) do |byte|
        @io << byte.to_i(2).chr
        ''
      end
    end

    def finish
      @events << false
      encode_events
      # fill up remaining byte with "1"s:
      rest = @bits.size % 8
      if rest != 0
        @bits << "1" * (8 - rest)
      end
      flush_bytes

    end
  end

  class Decoder
    def bits(string)
      string.unpack("B*")[0]
    end

    def initialize io
      @io = io
      @exponent = nil
      @bits = ''
      @t = @n = nil
    end

    def exponent
      return @exponent if @exponent
      e = @io.getc
      if e
        @exponent = e
      else
        raise ExponentUndefined.new
      end
      @exponent
    end

    def add_events
      n = @n
      n += @t * 2**exponent if @t
      @t = @n = nil
      @events += SecretAgent00111CommunicationGizmo.unrle([n])
    end

    def decode_bits
      loop do
        found = false
        if @bits =~ /^(1+)0/
          @t = $1.size
          @bits.sub!(/^(1+)/, '')
          found = true
        end
        re = Regexp.new("^0([01]{#{exponent}})")
        if @bits =~ re
          @n = $1.to_i(2)
          @bits.sub!(re, '')
          add_events
          found = true
        end
        return unless found
      end
    end

    def read
      @events = []
      begin
        exponent
        data = @io.read
        @bits += bits(data)
        decode_bits
      rescue ExponentUndefined
        # exponent not available yet in stream, try again later
      end
      @events
    end
  end
end
