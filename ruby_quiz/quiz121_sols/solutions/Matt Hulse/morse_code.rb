#Author: Matt Hulse
#File  : morse.rb
#Email : matt.hulse@gmail.com
#Web   : http://www.matt-hulse.com

class Morse

	attr_reader :morse_code, :message, :result

	def initialize(message)
		@morse_code = { :A => '.-', :B => '-...', :C => '-.-.',
			:D => '-..', :E => '.', :F => '..-.', :G => '--.',
			:H => '....', :I => '..', :J => '.---', :K => '-.-',
			:L => '.-..', :M => '--', :N => '-.', :O => '---',
			:P => '.--.', :Q => '--.-', :R => '.-.', :S => '...',
			:T => '-', :U => '..-', :V => '...-', :W => '.--',
			:X => '-..-', :Y => '-.--', :Z => '--..'
		}
		@message = message
	end

	def translate
		@result = do_translation(@message).flatten
		puts "Translation Complete"
		puts "#{@result.length} interpretations found."
	end

	def do_translation(str)
		result = Array.new

		(1..4).each{|n|
			morse = str[0,n]
			this_char = decode(morse)
			if(this_char.nil?) then
				puts "Invalid char, skipping to next" if $DEBUG
				next
			else
				#is a valid character
				if(n == str.size)
					result << this_char
				elsif(n < str.size)
					result << do_translation(str[n,str.size]).flatten.collect{|c|
						this_char + c
					}
				end
			end
		}

		return result
	end

	def encode(char)
		encoded = ""
		if(char.size > 1) then
			char.split("").each{|letter|
				encoded += encode(letter) + "|"
			}
			encoded.chop!
		else
			result = @morse_code.find{|key,value| key == char.to_sym}
			if(result.nil?)
				return nil
			else
				encoded = result[1].to_s
			end
		end

		encoded
	end

	def decode(morse)
		result = @morse_code.find{|key,value| value == morse}
		if (not result.nil?) then
			result[0].to_s
		else
			return nil
		end
	end

	def show_result
		@result.each{|res|
			printf("#{encode(res)}%25s\n",res)
		}
	end
end


if __FILE__ == $0 then

	code = ARGV[0] ||= "...---..-....-"

	morse = Morse.new(code)
	morse.translate
	morse.show_result if $VERBOSE
end
