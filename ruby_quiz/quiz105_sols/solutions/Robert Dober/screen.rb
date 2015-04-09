
class Screen
	def initialize size, &blk
		@lines = Array.new( size ){ [] }
		instance_eval &blk if blk
	end
	private
	def at c, pos_line, pos_col
		@lines[pos_line-1][pos_col-1] = c
	end
	def out stream=$stdout
		stream.puts self
	end
	def str_at s, pos_line, pos_col
		s.each_byte do
			|c|
			at c, pos_line, pos_col
			pos_col += 1
		end
	end
	def str_align s, align, pos_line, pos_col
		str_at "%#{align}s" % s.to_s, pos_line, pos_col
	end
	def to_s
		@lines.map{ |line| line.map{ |c| c.nil? ? " " : c.chr }.join}.join("\n")
	end
end

