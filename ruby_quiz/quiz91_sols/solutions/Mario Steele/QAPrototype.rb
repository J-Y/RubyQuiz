## RubyQuiz #91 - QAPrototype by Caleb Tennis
## Your Quiz: Write a Ruby module that can be mixed into a class.
## The module does the following: upon receiving a method call that
## is unknown to the class, have Ruby inform the user that it doesn't
## know that particular method call. Then, have it ask the user for
## Ruby code as input to use for that method call the next time it is
## called.

## Example:
## > object.some_unknown_method

## some_unknown_method is undefined
## Please define what I should do (end with a newline):

## >> @foo = 5
## >> puts "The value of foo is #{@foo}"
## >>

## Okay, I got it.

## >>> object.some_unknown_method
## "The value of foo is 5"

## [Editor's Note:
##
## I envision this could actually be handy for prototyping classes IRb.
## Bonus points if you can later print the source for all methods interactively
## defined.
##
## --JEG2]

## Participant:  Mario Steele
## Email: eumario@trilake.net

module QAPrototype
	ERROR = "!> "
	INPUT = "-> "
	
	def method_missing(meth,*args)
		if @qaproto_code.nil?
			@qaproto_code = {}
		end
		arg_names = []
		code = ""
		print ERROR, "#{meth} is undefined\n"
		if args.length != 0
			print ERROR, "Detected #{args.length} arguments given, please define their names below"
			print ERROR, "Put each argument name on a seperate line (end with newline)\n\n"
			loop do
				print INPUT
				input = STDIN.gets.strip
				if input == ""
					if arg_names.length != args.length
						print ERROR,ERROR, "invalid number of argument names!"
					else
						break
					end
				else
					arg_names << input
				end
			end
		end
		print ERROR, "Please define what I should do (end with new line)\n\n"
		loop do
			print INPUT
			input = STDIN.gets.strip
			if input == ""
				if arg_names.length > 0
					arg_names = arg_names.join(",")
				else
					arg_names = ""
				end
				code = "def #{meth}(#{arg_names})\n" + code + "end"
				self.class.class_eval(code)
				self.send("qaproto_record_method",*[meth,code])
				print "Okay, I got it.\n"
				break
			else
				code << input + "\n"
			end
		end
	end
	
	def qaproto_record_method(meth,code)
		@qaproto_code[meth] = code
	end
	
	def qaproto_display_method(meth)
		if @qaproto_code.has_key?(meth)
			print "Ok, here is the code for #{meth}\n"
			print @qaproto_code[meth] + "\n"
		else
			print "That is an unknown method to me.\n"
		end
	end
	
	def qaproto_write_method(meth,file)
		if @qaproto_code.has_key?(meth)
			if File.exist?(file)
				print "Ok, I am adding method definition #{meth} to file #{file}\n"
				File.open(file,"a+") do |fh|
					fh.write(@qaproto_code[meth])
				end
			else
				print "Ok, I am writting method definition #{meth} to file #{file}\n"
				File.open(file,"w") do |fh|
					fh.write(@qaproto_code[meth])
				end
			end
		else
			print "That is an unknown method to me.\n"
		end
	end
	
	def qaproto_dump_methods(file)
		print "Okay, I am writting all the methods that I have learned to file #{file}\n"
		File.open(file,"w") do |fh|
			@qaproto_code.each_value do |code|
				fh.write(code + "\n\n")
			end
		end
	end
end