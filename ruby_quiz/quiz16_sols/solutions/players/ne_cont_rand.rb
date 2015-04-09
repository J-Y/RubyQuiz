class NeoneyeContRand < Player
	QUEUE = [ :rock, :scissors, :paper ]
	def initialize( opponent )
		super
		@resume = lambda {}
	end
	def choose
		callcc{|@resume|}
		QUEUE[rand(QUEUE.size)]
	end
	def result( you, them, win_lose_or_draw )
		@resume.call if win_lose_or_draw == :lose
	end
end