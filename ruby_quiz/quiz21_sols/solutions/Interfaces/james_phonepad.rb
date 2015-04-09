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

loop do
	char = read_char.chr
	case char
	when /^(?:\d|\*|#)$/
		### Replace the following line with your algorithm. ###
		puts "You entered #{char}."
	when /q/i
		break
	else 
		puts "'#{char}' is not a key on the keypad."
	end
end