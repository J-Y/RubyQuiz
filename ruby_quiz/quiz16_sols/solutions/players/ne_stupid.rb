class NeoneyeStupid < Player
	QUEUE = [ :scissors, :rock, :paper ]
	def initialize( opponent )
		super
		@history = []
		@count = 0
		@lose = []
		@draw = []
		@win = []
	end
	def qs
		QUEUE.size
	end
	def queue(i)
		QUEUE[i % QUEUE.size]
	end
	def chance(level, a, b)
		(rand(100) < level) ? a : b
	end
	def choose
		@count += 1
		
		# 1st strategy: try all combinations
		return queue(@count-1) if @count <= qs
		
		# 2nd strategy: play on those where we won
		if @count <= qs*2
			you, them, wld = @history[@count - qs - 1]
			return case wld
			when :draw: chance(80, them, queue(@count - 1))
			when :lose: them
			when :win: you
			end
		end
		
		# 3rd strategy: what happened
		if @count == (qs*2)+1
			#puts "status1: win=#{@win.size} " +
			#	"draw=#{@draw.size} lose=#{@lose.size}"
		end

		if @count <= qs*3
			you, them, wld = @history[@count - qs*2 - 1]
			return case wld
			when :draw: chance(80, them, queue(@count - 1))
			when :lose: them
			when :win: you
			end
		end
		
		if @count == (qs*3)+1
			#puts "status2: win=#{@win.size} " +
			#	"draw=#{@draw.size} lose=#{@lose.size}"
		end

		you, them, wld = @history.last
		choice = case wld
		when :draw: chance(80, them, queue(@count - 1))
		when :lose: them
		when :win: you
		end
		
		if @lose.size > @win.size
			return them
		end
						
		return choice
	end
		
	def result( you, them, win_lose_or_draw )
		case win_lose_or_draw 
		when :lose: @lose << [you, them]
		when :draw: @draw << [you, them]
		when :win:  @win << [you, them]
		end
		@history << [you, them, win_lose_or_draw]
	end
end