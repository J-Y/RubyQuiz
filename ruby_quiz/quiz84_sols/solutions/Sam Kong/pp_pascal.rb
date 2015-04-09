class PascalTriangle

	include Enumerable

	attr_reader :rows

	def initialize row_count
		raise ArgumentException unless row_count.class == Fixnum
		raise "row_count must be greater than 0." unless row_count > 0
		@row_count = row_count
		generate_rows
	end

	def to_s
		max_width = @rows.flatten.max.to_s.size
		max_count = @rows.map{ |i| i.size }.max
		line_width = max_count * max_width * 2 - max_width
		separator = " " * max_width
		self.map do |row|
			row.map { |num| num.to_s.center(max_width)  }.join(separator).center(line_width)
		end.join("\n")
	end

	def each
		@rows.each { |row| yield row }
	end

private

	def generate_rows
		row = []
		@rows = (0...@row_count).to_a.inject([]) do |m, i|
			m << row = generate_row(row)
		end
		@rows.freeze
		@rows.each { |r| r.freeze }
	end

	def generate_row row
		result = [1]
		row.each_with_index do |el, idx|
			result << (idx == row.size - 1 ? 1 : el + row[idx + 1])
		end
		result
	end

end

if ARGV[0].nil? or ARGV[0] !~ /^\d+$/
	puts "Example: ruby pascal.rb 10"
	exit
end

row_count = ARGV[0].to_i
puts PascalTriangle.new(row_count).to_s
