class NeoneyeAntibias < Player
	QUEUE = [ :scissors, :rock, :paper ]
	def initialize( opponent )
		super
		@history = []
		@count = 0
		@lose = []
		@draw = []
		@win = []
		@counts = {:scissors=>0, :rock=>0, :paper=>0 }
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
			when :draw: chance(75, them, queue(@count - 1))
			when :lose: them
			when :win: you
			end
		end
		
		# 3rd strategy: what happened
		if @count == (qs*2)+1
			#puts "status1: win=#{@win.size} " +
			#	"draw=#{@draw.size} lose=#{@lose.size}"
		end

		you, them, wld = @history.last
		choice = case wld
		when :draw: chance(10, them, queue(@count - 1))
		when :lose: them
		when :win: you
		end
		
		#if @lose.size > @win.size
		#	return them
		#end
		
		cs = @counts[:scissors] 
		cr = @counts[:rock]
		cp = @counts[:paper]
		vs = cs*cs - (cr*cr+cp*cp)
		vr = cr*cr - (cs*cs+cp*cp)
		vp = cp*cp - (cr*cr+cs*cs)
		bet = (wld != :draw) ? them : choice
		l = 4
		bet = :rock if vr+l > vs and vr+l > vp
		bet = :scissors if vs+l > vr and vs+l > vp
		bet = :paper if vp+l > vr and vp+l > vs
						
		return chance(10, bet, (wld != :lose) ? them : choice)
	end
		
	def result( you, them, win_lose_or_draw )
		@counts[you] += 1
		case win_lose_or_draw 
		when :lose: @lose << [you, them]
		when :draw: @draw << [you, them]
		when :win:  @win << [you, them]
		end
		@history << [you, them, win_lose_or_draw]
	end
end