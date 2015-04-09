class Array
	def to_dice
		logic = [
		lambda{|n| '+-----+ '},
		lambda{|n| (n>3 ? '|O  ' : '|   ')+(n>1 ? ' O| ' : '  | ')},
		lambda{|n| (n==6 ? '|O ' : '|  ')+
		   (n%2==1 ? 'O' : ' ')+(n==6 ? ' O| ' : '  | ')},
		lambda{|n| (n>1 ? '|O  ' : '|   ')+(n>3 ? ' O| ' : '  | ')}
		]

		str=''
		5.times {|row|
			self.each {|n| str += logic[row%4].call(n) }
			str+="\n"
		}
		str
    end
end


#Example:
puts [1,2,3,4,5,6].to_dice
