class NumericMaze
	def solve (from, to)
		return [from] if from == to
		
		@done = {from => :from, -to => :to}
		@todo = [from, -to]
		@max = [from*2+2, to*2].max
		
		catch :found do
			loop do
				t = @todo.shift
				
				add_edge(2*t, t)
				add_edge(t+2, t) if (t <- 2) || (0 <= t)
				add_edge(t/2,t) if t.modulo(2) == 0
			end
		end
		return @result
	end
	
	def add_edge(new, from)
		return unless @done[new] == nil
		return if new > @max
		
		@done[new] = from
		
		if @done[-new] then #path found
			@result = calc_path(new.abs)
			throw :found
		end
		
		@todo.push new
	end
	
	def calc_path(middle)
		pathway = [middle]
	
		t = middle
		pathway.unshift(t) until (t = @done[t]) == :from
		
		t = -middle
		pathway.push(-t) until (t = @done[t]) == :to

		return pathway
	end
end
