class FuzzyTime < Time
	def initialize(*args)
		if args.length == 0
			@time = Time.now.hour()*3600 + Time.now.min()*60 + Time.now.sec()
			@fuzzyTime = @time - 300
			
			@execTime = Time.now
		else
			@time = args[0].hour()*3600 + args[0].min()*60 + args[0].sec()
			@fuzzyTime = @time - 300
			
			@execTime = Time.now
		end
	end
	
	def actual
			Time.now
	end
	
	def fuzzify
	
		if @time > 86400
			@time -= 86400
		end
			
		if Time.now - @execTime > 600
			@fuzzyTime = @time - 300
		end
		
		newTime = @time - 300 + rand(601)

		if @time >= 86100 and @time <= 86400 
			if newTime >= 86400 
				if @fuzzyTime >= 86100 
						@fuzzyTime = newTime - 86400
				else
					if newTime - 86400 > @fuzzyTime
						@fuzzyTime = newTime
					end
				end
			elsif newTime < 86400
				if @fuzzyTime > 86100
					if newTime > @fuzzyTime
						@fuzzyTime = newTime
					end
				end
			end
		elsif @time < 300
			if newTime < 0
				if @fuzzyTime > 600
					if @fuzzyTime < newTime + 86400
						@fuzzyTime = newTime + 86400
					end
				end
			elsif newTime == 0
				if @fuzzyTime > 600
					@fuzzyTime = newTime
				end
			elsif newTime > 0
				if @fuzzyTime > 600
					@fuzzyTime = newTime
				elsif @fuzzyTime < 600
					if @fuzzyTime < newTime
						@fuzzyTime = newTime
					end	
				end		
			end	
		else	
			if newTime > @fuzzyTime
				@fuzzyTime = newTime
			end
		end
	end
	
	def to_s
		fuzzify()
		"#{(@fuzzyTime/3600)}:#{if (@fuzzyTime/60)%60 < 10 
						   		0
								else
								((@fuzzyTime/60)%60)/10
								end}~" 
	end
	
	def advance seconds
		@time += seconds
		
		@execTime = Time.now
	end				
	
	def update 
		@time += Time.now - @execTime
		
		@execTime = Time.now
	end
end	