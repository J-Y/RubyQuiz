class Object
	def method_missing(method, *args, &blk)
		# Gather all possible methods it could be.
		possibleMethods = self.methods.select {|x| x =~ /^#{Regexp.escape(method.to_s)}/ }
		
		case possibleMethods.size
		# No matching method.
		when 0
			raise NoMethodError.new("undefined method `#{method}' for #{self.inspect}:#{self.class.name}")
		
		# One matching method, call it.
		when 1
			method = possibleMethods.first
			self.send(method, *args, &blk)
		
		# Multiple possibilities, return an array of the possibilities.
		else
			possibleMethods
		end
	end
end
