class NeoneyeThreshold < Player
	QUEUE = [ :rock,
		:scissors,
		:paper,
		:paper,
		:paper,
		:rock,
		:paper,
		:rock,
		:scissors ]

	def initialize( opponent )
		super
		@index = 0
		@history = []
		@count = 0
		@lost = 0
		
		@strategy = :choose_random
		@level1 = 75
		@level2 = 90
	end

	def choose
		if @count == 50 and @lost > 5
			#p "changing strategy"
			@level1 = 75
			@level2 = 100
		end
		if @count == 100 and @lost > 20
			#p "lets try something else"
			@level1 = 40
			@level2 = 90
		end
		if @count == 150 and @lost > 30
			#p "back to default strategy"
			@level1 = 80
			@level2 = 95
		end
		@count += 1
		send(@strategy)
	end
		
	def choose_random
		return :rock if @history.empty?
		
		you, them, wld = @history.last
		case wld
		when :draw
			@index = (@index + QUEUE.size + 1 - rand(2)) % QUEUE.size
			return QUEUE[@index]
		when :lose
			bet = (rand(100) > @level1) ? 0 : 1
			@index = (@index + bet) % QUEUE.size
			return QUEUE[@index]
		when :win
			bet = (rand(100) > @level2) ? 1 : 0
			@index = (@index + bet) % QUEUE.size
			return QUEUE[@index]
		end
		:rock
	end
	
	def choose_queue
		@index = (@index + 1) % QUEUE.size
		return QUEUE[@index]
	end
		
	def result( you, them, win_lose_or_draw )
		@lost += 1 if win_lose_or_draw == :lose
		@history << [you, them, win_lose_or_draw]
	end
end