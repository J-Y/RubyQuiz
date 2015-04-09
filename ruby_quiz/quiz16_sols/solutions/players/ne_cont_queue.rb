class NeoneyeContQueue < Player
	QUEUE = [ :rock, :scissors, :paper, :paper, :rock, :scissors ]
	def initialize( opponent )
		super
		@resume = lambda {}
		@index = 0
	end
	def choose
		callcc{|@resume|}
		@index = (@index + 1) % QUEUE.size
		#QUEUE[rand(QUEUE.size)]
		QUEUE[@index]
	end
	def result( you, them, win_lose_or_draw )
		@resume.call if win_lose_or_draw == :lose
	end
end