class NeoneyeRand < Player
	QUEUE = [ :rock,
		:scissors,
		:scissors ]

	def initialize( opponent )
		super
		@index = 0
		@history = []
	end

	def choose
		return :rock if @history.empty?
		
		you, them, wld = @history.last
		case wld
		when :draw
			@index = (@index + QUEUE.size + 1 - rand(2)) % QUEUE.size
			return QUEUE[@index]
		when :lose
			bet = (rand(100) > 75) ? 0 : 2
			@index = (@index + bet) % QUEUE.size
			return QUEUE[@index]
		when :win
			bet = (rand(100) > 80) ? 1 : 0
			@index = (@index + bet) % QUEUE.size
			return QUEUE[@index]
		end
		:rock
	end
		
	def result( you, them, win_lose_or_draw )
		@history << [you, them, win_lose_or_draw]
	end
end