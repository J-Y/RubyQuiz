#! /usr/bin/ruby

# Ruby quiz 127
# Ruben Medellin Cuevas <chubas7@gmail.com>

# Class that represents a pattern of colors
class Pattern
	
	attr_accessor 	:lines, 	# Array of colors indicating the pattern
			:thickness, 	# Indicates thickness of the gradient strips
			:separator	# Indicates wheter a separator between
					# gradients has been set
	
	# Default constructor
	def initialize(thickness = 5, lines = [])
		@thickness = thickness
		@lines = lines
	end 

	# Appends an object to the pattern
	def <<(obj)
		case obj
		# When is a number, sets the thickness of the gradient
		when Numeric
			@thickness = obj
		# When is a separator, appends the lines of such to the pattern
		when Separator
			@lines += obj.lines
			@separator = true
		# Allows to mix two patterns together 
		when Pattern
			@lines += obj.lines
		# When is a color, creates a gradient from the last color in the
		# pattern, or starts a new one if the pattern is empty or
		# the separator has not been set yet
		when *colors.keys
			color = obj
			if @lines.empty? or @separator
				@lines += [color] * @thickness
				@separator = false
			else
				@lines += make_gradient(@lines.last, color, @thickness)
			end
		else
			# Should not get here.
			raise ArgumentError, "#{obj} should be a number, a color or a Separator"
		end
		self #Returns itself, allowing for concatenation
	end

	# Takes two colors and returns the array of colors of the gradient.
	# Depending on the value of thickness, the colors blend by
	# incrementing the thickness of the second color and decrementing
	# the one of the first color.
	def make_gradient(color1, color2, thickness = @thickness)
		arr = (1..thickness).map{|n| [color1] * (thickness - n) + [color2] * n}
		arr.flatten
	end
	
	# Array containing the color names
	@@COLOR_NAMES = [:black, :red, :green, :yellow, :blue, :pink, :cyan, :white]
	def self.COLOR_NAMES
		@@COLOR_NAMES
	end

	# Array containing the color codes
	@@COLOR_CODES = Hash[ * "KRGYBPCW".split('').zip(@@COLOR_NAMES).flatten ]
	def self.COLOR_CODES
		@@COLOR_CODES
	end

	# Parses the string, and returns an array containing
	# the objects to append. See options parser
	def self.parse_colors(string)
		arr = []
		until string.empty?
			if match = string.slice!( /\A\([KRGYBPCW],\d+\)/ )
				arr << Separator[@@COLOR_CODES[match[/\w/]], match[/\d+/].to_i]
			elsif match = string.slice!( /\A\(\d+\)/ )
				arr << match[/\d+/].to_i
			elsif match = string.slice!( /\A[KRGYBPCW]/ )
				arr << @@COLOR_CODES[match]
			else
				puts "Invalid Pattern Option: #{string}"
				exit
			end
		end
		arr
	end

end

# A separator, consisting on a strip of given color and thickness
class Separator < Pattern
	
	def self.[](color, width = 5)
		return new(width, [color] * width)
	end

end

# Specifies terminal colors
module TerminalColors

	COLORS = Hash[* Pattern.COLOR_NAMES.zip([*100..107].map{|n|"\e[#{n}m"}).flatten]
	CLEAR = "\e[0m"

end

# Pattern for terminal output
class Terminal_Pattern < Pattern

	include TerminalColors

	def display( options )
		orientation = 	options[:orientation] || :vertical
		width = 		options[:width] || @lines.size
		height = 		options[:height] || @lines.size
		case orientation
			when :horizontal
				height.times{ @lines.each{|n| print colors[n] + " " + CLEAR }; puts }
			when :diagonal_down, :diagonal_up
				size = @lines.size
				for w in 0...height
					for h in 0...width
						index = ((w + (orientation == :diagonal_up  ? height - h : h))/2) % size
						print colors[@lines[index]] + " " + CLEAR unless h > width
					end
					puts
				end
			else
				1.upto(height){|n| puts( colors[ (@lines[n % lines.size] ) ] + ' ' * width + CLEAR + "\n")}
		end
	end

	def colors
		COLORS
	end

end

# Indicates PPM colors
module PPM_Colors
	
	require 'enumerator'
	
	COLORS = {}
	n_item = 0
	[
		0,		0,		0,		# Black
		255,	0,		0,		# Red
		0,		150,	0,		# Green
		200,	200,	0,		# Yellow
		0,		0,		255,	# Blue
		255,	0,		255,	# Pink
		0,		255,	255,	# Cyan
		255,	255,	255		# White
	].each_slice(3){|color| COLORS[Pattern.COLOR_NAMES[n_item]] = color.pack("C*"); n_item += 1 }

	def colors
		COLORS
	end

end

# PPM Image pattern
class PPM_Pattern < Pattern
	
	include PPM_Colors
	
	def display( options )
		orientation = 	options[:orientation] || :vertical
		width = 		options[:width] || @lines.size
		height = 		options[:height] || @lines.size
		filename =		options[:filename] || "MexicanBlanket.ppm"
		filename << ".ppm" unless filename[-4..-1] == ".ppm"
		File.open(filename, "w") do |image|
			image.puts "P6"
			image.puts "#{width} #{height} 255"
			case orientation
				when :horizontal
					height.times{ @lines.each{|n| print colors[n] + " " + CLEAR } }
				when :diagonal_down, :diagonal_up
					size = @lines.size
					for w in 0...height
						for h in 0...width
							index = ((w + (orientation == :diagonal_up  ? height - h : h))/2) % size
							image.print colors[@lines[index]] unless h > width
						end
					end
				else
					1.upto(height){|n| image.print( colors[ (@lines[n % lines.size] ) ] * width)}
			end
		end
		puts "Image succesfully created: #{filename}"
	end
end


# Main program
if __FILE__ == $0
	
	require "optparse"
	
	# General options
	options = {}
	# Options about the format of the pattern
	format = {}

	ARGV.options do |opts|
		opts.banner = "Pattern generator\nUsage:  #{File.basename($0)} [OPTIONS]\n"

		opts.on("-t", "--terminal", "Unix terminal display.") do
			options[:output] = Terminal_Pattern
		end

		opts.on("-i", "--image", "PPM image display.") do
			options[:output] = PPM_Pattern
		end

		opts.on("-w", "--width INTEGER", Integer, "Set pattern width.") do |width|
			format[:width] = width
		end

		opts.on("-h", "--height INTEGER", Integer, "Set pattern height.") do |height|
			format[:height] = height
		end

		opts.on("-o", "--orientation CHARACTER", String, <<-ORIENTATION
Indicates orientation of the pattern, where can be any of the following:
	v, V, vertical
	h, H, horizontal
	du, DU, diagonal_up
	dd, DD, diagonal_down
		ORIENTATION
		) do |o|
			format[:orientation] = case o
				when 'v', 'V', 'vertical'
					:vertical
				when 'h', 'H', 'horizontal'
					:horizontal
				when 'du', 'DU', 'diagonal_up'
					:diagonal_up
				when 'dd', 'DD', 'diagonal_down'
					:diagonal_down
				else
					nil
			end
		end

		opts.on("-c", "--colors STRING", String, <<-INSTRUCTIONS
Indicates colors of the pattern from command line.
	Should be a quoted string of the form
		
		[(THICKNESS)][COLOR][SEPARATOR(COLOR, THICKNESS)]

	Where
		Thickness: 
			Decimal number representing the thickness of the next gradient
		Color:
			A letter from this set:\n#{Pattern.COLOR_CODES.sort.map{|k, v| "\t\t\t\t#{k} => #{v.to_s.upcase}\n" }}
		SEPARATOR:
				A color of the above and a number inside parenthesis separated by a comma,
				to put a separator between gradients

	Example:
		'(10)RB(5)YK(G,7)(W,5)(R,7)(5)PY'
		INSTRUCTIONS
		) do |string|
			options[:colors] = Pattern.parse_colors(string)
		end
		
		opts.on("-f", "--filename STRING", String, "File to save the image (PPM only)") do |filename|
			format[:filename] = filename
		end
		
		opts.separator "Common Options:"
		
		opts.on( "-?", "--help",
			"Show this message." ) do
			puts opts
			exit
		end

		begin
			opts.parse!
		rescue OptionParser::ParseError => e
			puts e, opts
			exit
		end

	end
	
	pattern = (options[:output] || Terminal_Pattern).new
	
	# Default patterns when no specified
	string = case pattern
		when Terminal_Pattern
			"RBY"
		else
			"KRP(K,5)YGK(G,7)(W,5)(R,7)(G,25)(3)KRY(K,2)YRK(G,15)(R,7)(W,5)(G,7)(7)KRY(K,5)(6)WBK"
	end

	(options[:colors] || Pattern.parse_colors(string)).each{|e| pattern << e}
	pattern.display( format )

end