require 'screen'
class Tournament
	def initialize n
		@n = n.to_i
		abort "illegal number #@n" unless @n > 0
		@outputs = []
		[*0..(@n - 1).to_s(2).length].inject([0]){
			|pairs,n|
			@outputs.unshift pairs
			pairs.map{|p| [p, ( 1 << n ) * 2 - 1 - p]}.flatten
		}
		@outputs.map!{ |col| col.map!{|i| i < @n ? i + 1 : :bye} }
	end
	def print
		data = @outputs
		Screen.new data.first.length * 2 do
			data.each_with_index do
				|output, col|
				output.each_with_index do
					|player, row|
					main_row = 2**col + row*2**(col+1)
				        str_align player, 4, main_row, 6*col+5
					str_at "-"*5 << "+", main_row, 6*col+9 unless
						output.length == 1
					if col > 1 then
						(2**(col-1)-1).times do
							|t|
							at ?|, main_row -1-t, 6*col+8
							at ?|, main_row +1+t, 6*col+8
						end
					end
					
				end

			end
			out
		end
	end
end

Tournament.new( ARGV.first || "14" ).print
