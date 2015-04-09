class HumanPlayer < Player
	def choose_move
		print 'Enter your move choice: '
		gets.chomp.to_i
	end
end