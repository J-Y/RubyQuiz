require 'stringio'

class SecretAgent00111CommunicationGizmo
	
	class UndefinedRLE < StandardError
	end
	
private

	class Rle
		def initialize
			@data = []
			@count = 0
		end
		
		def <<(event)
			if event
				@count += 1
			else
				@data << @count
				@count = 0
			end
		end
		
		def get
			@count == 0 ? @data : nil
		end
	end
	
	class UnRle
		def initialize
			@data = []
		end
		
		attr_reader	:data
		
		def <<(count)
			count.times { @data << true }
			@data << false
		end
	end
	
public	
	
	class Encoder < Rle
		def initialize(exponent, output)
			super()

			@output = output
			@exponent = exponent

			@byte = 0
			@byte_bit = 0x80
			
			insert @exponent, 8
		end
		
		def <<(event)
			super(event)
			while count = @data.shift
				(count >> @exponent).times { insert 1 }
				insert 0
				insert count, @exponent
			end
		end
		
		def finish
			self << false
			insert 1 while @byte_bit != 0x80
		end
		
	private

		def insert(num, bits = 1)
			(bits-1).downto(0) do |n|
				@byte |= @byte_bit if num[n] == 1
				if (@byte_bit >>= 1) == 0
					@output.putc @byte

					@byte_bit = 0x80
					@byte = 0
				end
			end
		end
	end
	
	class Decoder < UnRle
		def initialize(input)
			super()
			
			@exponent = 0
			@input = input

			@count = 0
			@remainder_bit  = 0
		end

		def exponent
			decode
			@exponent
		end
		
		def read
			decode
			data = @data
			@data = []
			data
		end

	private
	
		def decode
			while byte = @input.getc
				if @exponent == 0
					@exponent = byte
				else
					insert byte
				end
			end
		end
		
		def insert(byte)
			7.downto(0) do |n|
				if @remainder_bit == 0
					if byte[n] == 1
						@count += 1 << @exponent
					else
						@remainder_bit = 1 << (@exponent - 1)
					end
				else
					@count += @remainder_bit if byte[n] == 1
					if (@remainder_bit >>= 1) == 0
						self.<<(@count)
						@count = 0
					end
				end
			end
		end
	end
		
	def SecretAgent00111CommunicationGizmo.rle(arr)
		rle = Rle.new

		arr.each do |event|
			rle << event
		end
		out = rle.get
		
		raise UndefinedRLE, "undefined rle" unless out and not out.empty?
		out
	end
	
	def SecretAgent00111CommunicationGizmo.unrle(arr)
		unrle = UnRle.new
		
		arr.each do |count|
			unrle << count
		end
		
		unrle.data
	end
	
	def SecretAgent00111CommunicationGizmo.encode(arr, exp)
		io = StringIO.new
		encoder = Encoder.new(exp, io)
		
		arr.each do |event|
			encoder << event
		end
		encoder.finish
		
		io.string
	end
	
	def SecretAgent00111CommunicationGizmo.decode(bits)
		io = StringIO.new(bits)
		
		decoder = Decoder.new(io)
		arr = decoder.read
		
		arr.pop if arr.last == false
		arr
	end
	
end
