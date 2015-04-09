class NEQueuePlayer < Player
	QUEUE = [ 
		:rock, :rock, :rock, :rock,
		:scissors, :scissors, :paper, :scissors,
		:paper, :paper, :scissors, :paper, 
		:rock, :rock, :rock, :scissors,
		:paper, :scissors, :scissors, :paper,
		:rock, :paper, :paper, :rock,
		:scissors, :paper, :rock, :rock,
		:scissors, :rock, :scissors, :scissors,
		:paper, :scissors, :paper, :paper 
	]
	def initialize( opponent )
		super
	@index = 0
	end
	def choose
		choice = QUEUE[@index]
		@index += 1
		@index = 0 if @index == QUEUE.size
		choice
	end
end