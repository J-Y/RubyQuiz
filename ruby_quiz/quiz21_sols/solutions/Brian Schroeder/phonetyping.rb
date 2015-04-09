#!/usr/bin/ruby

# Try entering:
# 843054689

begin
	require "Win32API"

	def read_char
		Win32API.new("crtdll", "_getch", [], "L").Call
	end
rescue LoadError
	def read_char
		system "stty raw -echo"
		STDIN.getc
	ensure
		system "stty -raw echo"
	end
end

# Basis for input algorithms. (Movement in the text, deletion etc.)
class InputMethod
	attr_accessor :text, :cursor, :map

	def initialize
		@text = ''
		@cursor = 0
		@map = (([' ', '!?-*+/='] + %w(abc def ghi jkl mno pqrs tuv wxyz)) + ['()[]{}<>', '\"\'\#&%\$']).map{|r| r.split(//)}
	end

	def insert(char)
		@text.insert(@cursor, char)
		@cursor += 1
	end

	def replace(char)
		@text[@cursor-1] = char
	end

	def right
		@cursor = [@cursor+1, @text.length].min
	end

	def left
		@cursor = [@cursor-1, 0].max
	end

	def delete
		return if @cursor == @text.length
		@text.slice!(@cursor)
	end

	def backspace
		return if @cursor == 0
		@text.slice!(@cursor-1)
		@cursor -= 1
	end

	def display
		print "    \r#{@text.dup.insert(@cursor, '_')}\r#{@text[0,@cursor]}"
		$stdout.flush
	end

	def invalid
		print "\r" + "INVALID " * 10
		$stdout.flush
		sleep(0.3)
		print "\r" + "        " * 20
		self.display
	end
end

# Standard dumb input method.
class Multitap < InputMethod
	def initialize
		super()
		@lastkey = nil
		@repeats = 0
		@last_time = 0
	end

	def keypress(key)
		case key
		when /[0-9\#*]/
			if key == '#'
				key = 10
			elsif key == '*'
				key = 11
			else
				key = key.to_i
			end
			if key == @lastkey and (Time.new - @last_time).to_f < 1.5
				@repeats += 1
				self.replace(@map[key][@repeats % @map[key].length])
			else
				@repeats = 0
				self.insert(@map[key][@repeats % @map[key].length])
			end
			@last_time = Time.new
		when :right
			self.right
			@last_time = 0
		when :left
			self.left
			@last_time = 0
		when :del
			self.delete
			@last_time = 0
		when :backspace
			self.backspace
			@last_time = 0
		end
		@lastkey = key
	end
end

require 'markovtap'

# More intelligent input method based on a markov modell
class Markovtap < Multitap
	def initialize(database_file = 'typedatabase')
		super()
		$stderr.puts "Loading database"
		raise "Database file must exist. Use learn to learn a new database from a corpus" unless File.exist?(database_file)
		@database = MarkovDict.load(database_file)
		@max_prefix = @database.max_prefix
		$stderr.puts "Done"
	end

	private
	def update(map, state)
		puts "", "State: #{state.inspect}"
		@map[map] = @map[map].sort_by{|a| -@database.popularity(a, state.to_s) }
		p @map[map]
	end

	public
	def keypress(key)
		case key
		when /[0-9\#*]/
			if key == '#'
				key = 10
			elsif key == '*'
				key = 11
			else
				key = key.to_i
			end

			if key == @lastkey and (Time.new - @last_time).to_f < 1.5
				@repeats += 1
				self.replace(@map[key][@repeats % @map[key].length])
			else
				# Update Mapping based on previous state
				state = @text[[0, @cursor-@max_prefix].max..@cursor]
				update(key.to_i, state)

				@repeats = 0
				self.insert(@map[key][@repeats % @map[key].length])
			end
			@last_time = Time.new
		else
			# Behave as multitap behaves
			super(key)
		end
		@lastkey = key
	end
end

# Get Keypresses from the input device and send them to the input method
class MobilePhone
	attr_accessor :input_method

	def initialize
		@input_method = Multitap.new
	end

	# Not very nice, but it works (at least in an xterm).
	def input
		loop do
			char = read_char.chr
			case char
			when /^(?:\d|\*|#)$/
				@input_method.keypress(char)
			when /q/i
				break
			when "\177"
				@input_method.keypress(:backspace)
			when "\e"
				s = read_char.chr + read_char.chr
				case s
				when '[C' then @input_method.keypress(:right)
				when '[D' then @input_method.keypress(:left)
				when '[3' then
					if read_char.chr == '~'
						@input_method.keypress(:del)
					else
						@input_method.invalid
					end
				else
					@input_method.invalid
				end
			else
				@input_method.invalid
			end
			@input_method.display
		end
	end
end


if __FILE__ == $0

	require 'optparse'

	class PhoneOptions < OptionParser
		attr_reader :input_method, :help
		def initialize
			super()
			@help = false
			@database_file = 'typedatabase.6'
			@input_method = Multitap.new
			self.on("-t", "--multitap", '(Default input method)')  { @input_method   = Multitap.new }
			self.on("-m", "--markovtap FILENAME", 'Intelligent input method.',
							'Specify a dictionary to load.', String) { | v | @input_method = Markovtap.new(v) }
			self.on("-?", "--help") { @help = true }
		end
	end

	options = PhoneOptions.new
	begin
		options.parse!(ARGV)
	rescue => e
		puts e
		puts options
		exit
	end

	if options.help
		puts options, ''
		puts ['Keys:','    0: Space', '    1-9: A-Z', '    #*: Symbols',
			'    Left, Right: Move left, right', '    Delete, Backspace: Delete previous, next letter.']
		exit
	end

	m = MobilePhone.new
	m.input_method = options.input_method
	m.input
end
