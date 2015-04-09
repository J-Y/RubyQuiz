
module SecretAgent00111CommunicationGizmo

  class UndefinedRLE < Exception
  end

  def self.rle data
    counter = 0
    code = []
    raise UndefinedRLE.new if data.empty? || data[-1]
    data.each do |value|
      if value
        counter += 1
      else
        code << counter
        counter = 0
      end
    end
    code
  end

  def self.unrle code
    data = []
    code.each do |value|
      data += [true]*value + [false]
    end
    data
  end

  def self.encode array, exponent
    bitstring = padding(exponent.to_s(2), 8)
    to_encode = rle(array + [false])
    to_encode.each do |value|
      bitstring += encode_value value, exponent
    end
    unless (bitstring.length % 8).zero?
    bitstring += "1"*(8 - bitstring.length % 8)
    end
    [bitstring].pack("B*")
  end

  def self.encode_value value, exponent
    bitstring = ""
    nb_bits = exponent
    base = 2**exponent
    quotient = value/base
    remainder = value%base
    bitstring += "1"*quotient + "0"
      code = remainder.to_s 2
      code = padding(code, nb_bits)
    bitstring += code
    bitstring
  end

  def self.padding code, size
    "0"*(size - code.length) + code
  end

  def self.decode bitstring, remaining = false
    bitstring = bitstring.unpack("B*")[0]
    exponent = bitstring.slice!(0,8).to_i 2
    code = []
    count = 0
    value = 0
    nb_bits = exponent
    base = 2 ** exponent
    count_total = 0
    until bitstring.empty?
      count_total += 1
      byte = bitstring.slice! 0
      if byte == ?1
        count += 1
      else
        value = count * base
        count_total += nb_bits
          rem = bitstring.slice!(0,nb_bits).to_i 2
        code << value + rem
        count = 0
      end
    end
    unless (count_total % 8).zero?
      bitstring.slice!(0, 8-(count_total%8))
    end
    decoded = unrle(code)
    decoded.pop
    if remaining
      [decoded,bitstring]
    else
      decoded
    end
  end

  class Encoder

    attr_reader :exponent, :io

    def initialize exponent, io
      @exponent = exponent
      @io = io
      @data = []
    end

    def << to_encode
      @data << to_encode
    end

    def finish
      code = SecretAgent00111CommunicationGizmo.encode(@data, exponent)
      io << code
    end

  end

  class Decoder

    attr_reader :io, :exponent

    attr_accessor :code, :quotient, :count, :base, :content, :state

    def initialize io
      @io = io
      @exponent = nil
      self.code = ""
      self.count = 0
      self.quotient = 0
      self.state = :quotient
      read_exponent
    end

    def read_exponent
      if exponent.nil? and not io.eof?
        exp = io.read(1)
        @exponent = exp.unpack("B*")[0].to_i 2
        self.base = 2 ** exponent
      end
    end

    def read
      read_exponent
      return [] if io.eof?
      values = []
      code.concat io.read.unpack("B*")[0]
      until code.empty?
        case state
        when :quotient
          byte = code.slice! 0
          if byte == ?1
            self.count += 1
          else
            self.quotient = count * base
            self.state = :remainder
            self.count = 0
          end
        when :remainder
          if code.length >= exponent
            rem = code.slice!(0,exponent).to_i 2
            nb = quotient + rem
            values.concat([true]*nb + [false])
            self.state = :quotient
          else
            break
          end
        end
      end
      values
    end

  end

end
