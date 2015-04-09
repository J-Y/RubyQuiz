module Enumerable

	# Return an array containing the sub-ranges of sorted contents of the receiver
	# Each element must be comparable, and must respond to succ
	def subranges
		range_start = range_end = nil
		subranges = []
		self.sort.each do |elem|
			if range_start.nil?
				range_start = range_end = elem
			else
				if range_end.succ == elem
					range_end = elem
				else
					subranges << (range_start..range_end)
					range_start = range_end = elem
				end
			end
		end
		subranges << (range_start..range_end) unless range_start.nil?
		subranges
	end

end

