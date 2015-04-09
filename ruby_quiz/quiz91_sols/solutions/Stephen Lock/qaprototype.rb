module QAPrototype
	@@methods = Hash.new
	def method_missing( name, *args )
		puts "Undefined method " + self.class.to_s + "." + name.to_s
		puts "How do you want me to handle this method? (end with a newline)"
		$stdout.flush
		method = Array.new
		begin
			line = gets
			method << line
		end until line.eql?("\n")
		@@methods[name]=method
		self.class.instance_eval do
			define_method(name) { eval(method.join) }
		end
		puts "OK"
	end
	
	def print_defined_methods
		@@methods.each_pair { |key, value|
			puts key.to_s + ":"
			puts value
		}
	end
end
