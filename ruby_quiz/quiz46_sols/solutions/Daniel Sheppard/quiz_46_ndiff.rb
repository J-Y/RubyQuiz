require 'generator'
require 'pathname'
require 'optparse'
require 'bigdecimal'

class NumberLine
	include Enumerable
	def initialize(line)
		@line = line
	end
	def each
		@line.scan(/((-)?([0-9]+|\.)\.?([0-9]+)?[Ee]?([-+]?[0-9]+)?)/) do |match|
			yield BigDecimal.new(match[0])
		end	
	end
	def to_s
		@line
	end
end

class NumericalDifferencer
	attr_accessor :digits, :tolerance
	def initialize
		@digits = 0
		@tolerance = 0.0
	end
	def each_diff(file1, file2)
		line = 0
		diff = nil
		SyncEnumerator.new(file1, file2).each do |line1, line2|
			line1, line2 = NumberLine.new(line1), NumberLine.new(line2)
			line += 1
			num_enum =  SyncEnumerator.new(line1, line2)
			if num_enum.all? do |a,b|
				a,b = a.round(@digits-1), b.round(@digits-1) unless @digits == 0
				(a - b).abs <= @tolerance 
			end
				if diff
					yield diff
					diff = nil
				end
			else
				diff = NumericalDiff.new(line) unless diff
				diff.add_lines(line1, line2)
			end
		end
		yield diff if diff
	end
end

class NumericalDiff
	attr_reader :start_line, :left, :right
	def initialize(start_line)
		@start_line = start_line
		@left = []
		@right = []
	end
	def add_lines(line1, line2)
		@left << line1
		@right << line2
	end
	def to_s
		lines = "#{@start_line},#{@start_line + @left.length - 1}"
		str = "#{lines}c#{lines}\n"
		str << @left.collect { |x| "< #{x}" }.join
		str << "---\n"
		str << @right.collect { |x| "> #{x}" }.join
	end
end

differ = NumericalDifferencer.new
quiet = false
statistics = false

opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] file1 file2"

        opts.separator ""
        opts.separator "Numerically compare files line by line, numerical field by numerical field."
        opts.separator ""
        opts.on("-d", "--digits INT", Integer,
                "Maximum number of significant digits that should match.","(default: 0)") do |digits|
          differ.digits = digits
        end
        opts.on("-t", "--tolerance DBL", String, 
                "Tolerate <= DBL distance between numbers.","(default: 0.0)") do |tolerance|
          differ.tolerance = BigDecimal.new(tolerance)
        end	
        opts.on("-h", "--help", "Output this help.") do |help|
		puts opts
		exit 0
        end
	opts.on("-q", "--quiet", "No output, just exit code.") do |value|
		quiet = value
	end
	opts.on("-s", "--statistics", "Provide comparison statistics only.") do |value|
		statistics = value
	end	
end

begin
	opts.parse!(ARGV)
	raise "--quiet and --statistics are mutually exclusive" 	if quiet && statistics
	raise "Must pass two filenames" unless ARGV.length == 2
	files = ARGV.collect { |x| Pathname.new(x) }
	files.each do |f| 
		unless f.exist? && f.file?
			raise "'#{f}' does not exist"
		end
	end
	File.open(files[0]) do |file1|
		File.open(files[1]) do |file2|
			if(statistics)
				distances = []
				SyncEnumerator.new(file1, file2).each do |line1, line2|
					line1, line2 = NumberLine.new(line1), NumberLine.new(line2)
					SyncEnumerator.new(line1, line2).collect { |num1, num2| distances << (num1 - num2).abs }
				end
				class << distances
					def median
						sorted = self.sort
						mid = sorted.size / 2
						if sorted.size % 2 == 0
						    (sorted[mid] + sorted[mid - 1]) / 2
						else
						    sorted[mid]
						end
					end
					def mean
						self.inject(0) { |x, sum| sum + x / self.size}
					end
				end
				puts(<<-EOF)
Numbers compared: #{distances.size}
Distance range: #{distances.min}..#{distances.max}
Median distance: #{distances.median}			
Mean distance: #{distances.mean}
				EOF
			elsif(quiet)
				differ.each_diff(file1, file2) do |diff|
					exit 1
				end
				exit 0
			else
				different = false
				differ.each_diff(file1, file2) do |diff|
					different = true
					puts diff
				end
				exit(different ? 1 : 0)
			end
		end
	end	
rescue => e
	warn e
	warn opts
	exit 1
end



