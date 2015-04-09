module FastProto
	# get personal...
	begin
		$NAME = ENV['USER']		
		$NAME ||= ENV['HOME'].split("\\").last
		$NAME ||= `whoami`
	rescue
	end		

	# ahhh, yes, the magical method_missing
	def method_missing(sym, *args)
		@code_cache ||= {}		

		# to get the source for a method you added, use instance.source_for<method name>
		fp_print_source($1.intern) and return if sym.to_s =~ /source\_for\_(.*)/		
		
		# get the argument names
		argument_names = fp_get_argument_names(sym, args.size)

		# get the method body
		code = fp_get_code(sym)

		unless code.strip.size.zero?
			fp_add_method(sym, argument_names, code.gsub(/^.*\n/) { |m| "  " + m })
		else
			puts "#{$NAME}, you didnt write any code, how could you!"
		end
	end

	# asks nicely for a list of argument names
	def fp_get_argument_names(method_name, how_many)
		argument_names = ""
		# if arguments were passed, ask for their names
		unless how_many.zero?
			STDOUT << <<-PROMPT
#{$NAME}, I noticed that you passed a few arguments to #{self.class.name}.#{method_name}, what would you
like them to be called?	Please separate argument names with a comma
such as this: name, address, phone\n
			PROMPT

			while argument_names.to_s.split(',').size != how_many
				argument_names = gets.strip
				argument_count = argument_names.split(',').size
				puts "Sorry #{$NAME}, both you and I know what you did, now fix it and we can put it\nbehind us." if argument_count != how_many.size
			end
		end		
		argument_names
	end

	# gets the ruby code for the new method from the user
	def fp_get_code(method_name)
		puts "#{$NAME}, please enter the code for #{self.class.name}.#{method_name} (end with a newline)\n"

		# read lines until a single newline is keyed
		code = ""
		until (STDOUT << "#> "; code_line = gets) == $/
			code << code_line
		end
	end

	# prints the source for a dynamically created method
	def fp_print_source(method_name)
		if @code_cache.include?(method_name)
			puts "Why #{$NAME}, the source for #{self.class.name}.#{method_name} just happens to be:\n#{@code_cache[method_name]}"
		else
			puts "Sorry #{$NAME}, you havent defined that method yet"
		end
		true
	end

	# adds the new method to the code cache and adds the method to the current instances class
	def fp_add_method(sym, argument_names, code)
		@code_cache[sym] = "#mixed into #{self.class.name}\ndef #{sym}(#{argument_names})\n#{code.rstrip}\nend"
		self.class.class_eval(@code_cache[sym])
	end
end
