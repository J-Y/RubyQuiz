class String
	def to_coords
		return [self[0] - ?a, self[1] - ?1]
	end
end

class Array
	def to_algebraic
		return (self[0] + ?a).chr + (self[1] + ?1).chr
	end
end


def where_can_jump_from (here, visited)
	col, row = here
	[
	 [col+2, row+1], [col+2, row-1], [col+1, row-2], [col-1, row-2],
	 [col-2, row-1], [col-2, row+1], [col-1, row+2], [col+1, row+2]
	].select { |c,r|
	 		r >= 0 && r < 8 && c >= 0 && c < 8 && !visited[c][r]
		}
end
	

def knight_path (start_pos, finish_pos, forbidden)
	visited = Array.new(8) { Array.new(8) }
	forbidden.each do |col,row| visited[col][row] = true end

	# special cases:
	# shortest path: no movement at all
	return [] if start_pos == finish_pos
	# impossible task:
	return nil if forbidden.include? finish_pos
	
	# setup...
	paths = [[start_pos]]
	visited[start_pos[0]][start_pos[1]] = true
	
	while !paths.empty?
		# pp paths.map {|p| p.map {|c| c.to_algebraic } }
		new_paths = []
		paths.each do |path|
			where_next = where_can_jump_from(path.last, visited)
			where_next.each do |coord|
				newpath = path.dup << coord
				if coord == finish_pos
					# clear first cell (start position)
					newpath.shift
					return newpath
				end
				c, r = coord
				visited[c][r] = true
				new_paths.push newpath
			end
		end
		paths = new_paths
	end
	
	return nil
end

start_pos = ARGV.shift.to_coords
finish_pos = ARGV.shift.to_coords
forbidden = ARGV.map {|arg| arg.to_coords }

result = knight_path start_pos, finish_pos, forbidden

if (result)
	result.map! { |coord| coord.to_algebraic }
	puts "[ " + result.join(" , ") + " ]"
else
	p nil
end
