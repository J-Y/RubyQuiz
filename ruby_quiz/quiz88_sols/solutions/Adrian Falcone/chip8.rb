class Integer

  def to_bin_string( bits=8 )
    s = ""
    ( bits - 1 ).downto(0) { |i| s << self[i].to_s }
    s
  end

  def to_1_digit_hex
    #simplified to_hex method because I'll only ever need one digit
    raise ArgumentError, "doesn't work on negatives" if self < 0
    raise ArgumentError, "#{self.to_s} is greater than 15" if self > 15
    self < 10 ? self.to_s : (self - 10 + ?A).chr
  end

end

class InvalidOpCodeError < StandardError
  def initialize( pos=nil )
    puts "Invalid Op Code starting at byte #{pos}." if pos
  end
end

class Chip8

  def initialize( io=STDIN, carry_on_op7=1 )
    raise ArgumentError, "Need an IO object" unless io.kind_of?( IO )
    @code = io
    @v = Array.new( 16, 0 )
    @carry_on_op7 = carry_on_op7
  end

  def parse
    hob = @code.getc
    lob = @code.getc
    raise EOFError, "File ends before opcode x0000" unless hob && lob
    case hob & 0xF0
      when 0x00
	if ( hob == 0 && lob == 0 )
	  @code.close rescue IOError
	  return nil
	else
	  raise InvalidOpCodeError.new( @code.pos - 2 )
	end
      when 0x10
	@code.seek( ( ( hob & 0x0F ) << 8 ) + lob, IO::SEEK_SET )
      when 0x30
	@code.seek( 2, IO::SEEK_CUR ) if ( @v[ hob & 0x0F ] == lob )
      when 0x60
	@v[ hob & 0x0F ] = lob
      when 0x70
	@v[ 0 ] = ( @carry_on_op7 && ( @v[ hob & 0x0F ] + lob > 255 ) ) ? 1 : 0
	@v[ hob & 0x0F ] += lob
	@v[ hob & 0x0F ] %= 256
      when 0x80
	x = hob % 16
	y = lob >> 4
	case lob & 0x0F
	  when 0x00 : @v[x] = @v[y]
	  when 0x01 : @v[x] |= @v[y]
	  when 0x02 : @v[x] &= @v[y]
	  when 0x03 : @v[x] ^= @v[y]
	  when 0x04
	    @v[0] = @v[x] + @v[y] > 255 ? 1 : 0
	    @v[x] += @v[y]
	    @v[x] %= 256
	  when 0x05
	    @v[0] = @v[x] < @v[y] ? 1 : 0
	    @v[x] -= @v[y]
	    @v[x] %= 256
	  when 0x06
	    if y == 0
	      @v[0] = @v[x] % 2
	      @v[x] = @v[x] >> 1
	    else
	      raise InvalidOpCodeError.new( @code.pos - 2 )
	    end
	  when 0x07
	    @v[0] = @v[y] < @v[x] ? 1 : 0
	    @v[x] = @v[y] - @v[x]
	    @v[x] %= 256
	  when 0x0E
	    if y == 0
	      @v[0] = @v[x] / 128
	      @v[x] = ( @v[x] << 1 ) % 256
	    else
	      raise InvalidOpCodeError.new( @code.pos - 2 )
	    end
	  else
	    raise InvalidOpCodeError.new( @code.pos - 2 )
	end
      when 0xC0
	@v[ hob & 0x0F ] = rand( 256 ) & lob
      else
	raise InvalidOpCodeError.new( @code.pos - 2 )
    end
    self
  end

  def dump_all
    16.times { |i| puts "V#{i.to_1_digit_hex}:#{@v[i].to_bin_string(8)}" }
    self
  end

end

if $0 == __FILE__
  begin
    f=File.open( ARGV[0], "r" )
    a=Chip8.new( f )
    while( a.parse ) do; end
    a.dump_all
  rescue IOError
    puts "Please enter a valid Chip8 file name.\nExample: ruby chip8.rb Chip8Test"
  end
end
