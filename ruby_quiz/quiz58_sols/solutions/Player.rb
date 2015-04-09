class Player
	attr_accessor :name
	attr_writer :game, :side
	
	def initialize( name )
		@name = name
	end
	
	def choose_move
		if @side==KalahGame::TOP
			(7..12).each { |i| return i if @game.stones_at?(i) > 0 }
		else
			(0..5).each { |i| return i if @game.stones_at?(i) > 0 }
		end
	end
end