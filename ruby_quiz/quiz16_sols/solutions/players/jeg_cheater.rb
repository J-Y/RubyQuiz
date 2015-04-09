#!/usr/biin/env ruby

class JEGCheater < Player
	def initialize( opponent )
		Object.const_get(opponent).class_eval do
			alias_method :old_choose, :choose
			def choose
				:paper
			end
		end
	end
	
	def choose
		:scissors
	end
end
