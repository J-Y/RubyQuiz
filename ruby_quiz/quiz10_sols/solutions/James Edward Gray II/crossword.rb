#!/usr/bin/env ruby

class Square
	@@count = 1
	
	def initialize( holds_letter = false )
		@holds_letter = holds_letter
		@edge = false
	end
	
	attr_reader :holds_letter
	attr_accessor :edge
	
	def render( row, top, left, right, bottom )
		if @holds_letter
			number = ""
			if (top.nil? or not top.holds_letter) and
			   (bottom and bottom.holds_letter)
				number = @@count.to_s
				@@count += 1
			elsif (left.nil? or not left.holds_letter) and
				  (right and right.holds_letter)
				number = @@count.to_s
				@@count += 1
			end
			
			if top.nil? and left.nil?
				row[0] << "######"
				row[1] << sprintf("#%-4s#", number)
				row[2] << "#    #"
				row[3] << "######"
			elsif top.nil?
				row[0] << "#####"
				row[1] << sprintf("%-4s#", number)
				row[2] << "    #"
				row[3] << "#####"
			elsif left.nil?
				row[1] << sprintf("#%-4s#", number)
				row[2] << "#    #"
				row[3] << "######"
			else
				row[1] << sprintf("%-4s#", number)
				row[2] << "    #"
				row[3] << "#####"
			end
		else
			if @edge
				if top.nil? and left.nil?
					row[0] << "      "
					row[1] << "      "
					row[2] << "      "
					row[3] << "      "
				elsif top.nil?
					row[0] << "     "
					row[1] << "     "
					row[2] << "     "
					row[3] << "     "
				elsif left.nil?
					row[1] << "      "
					row[2] << "      "
					row[3] << "      "
				else
					row[1] << "     "
					row[2] << "     "
					row[3] << "     "
				end
				if right and not right.edge
					row.each { |e| e.sub!(/ $/, "#") }
				end
				if left and not left.edge
					row.each { |e| e.sub!(/ (.{5})$/, '#\1') }
				end
				if top and not top.edge
					row[0].sub!(/ +(#?)$/) do |m|
						"#" * (m.length - $1.length) + $1
					end
				end
				if bottom and not bottom.edge
					row[3].sub!(/ +(#?)$/) do |m|
						"#" * (m.length - $1.length) + $1
					end
				end
			else
				if top.nil? and left.nil?
					row[0] << "######"
					row[1] << "######"
					row[2] << "######"
					row[3] << "######"
				elsif top.nil?
					row[0] << "#####"
					row[1] << "#####"
					row[2] << "#####"
					row[3] << "#####"
				elsif left.nil?
					row[1] << "######"
					row[2] << "######"
					row[3] << "######"
				else
					row[1] << "#####"
					row[2] << "#####"
					row[3] << "#####"
				end
			end
		end
	end
end

board = [ ]
while line = ARGF.gets
	board << [ ]
	line.chomp.delete(" ").each_byte do |c|
		if c == ?X 
			board[-1] << Square.new
		else
			board[-1] << Square.new(true)
		end
	end
end

loop do
	changed = false
	board.each_with_index do |row, y|
		row.each_with_index do |cell, x|
			next if cell.holds_letter or cell.edge
			
			if x == 0 or y == 0 or x == board[0].size - 1 or y == board.size - 1
				cell.edge = true
				changed = true
				next
			end
			
			top = board[y - 1][x]
			left = board[y][x - 1]
			right = board[y][x + 1]
			bottom = board[y + 1][x]
			if (top and top.edge) or (left and left.edge) or
			   (right and right.edge) or (bottom and bottom.edge)
				cell.edge = true
				changed = true
			end
		end
	end
	break if not changed
end

board.each_with_index do |row, y|
	drawn_row = ["", "", "", ""]
	row.each_with_index do |cell, x|
		top = y == 0 ? nil : board[y - 1][x]
		left = x == 0 ? nil : board[y][x - 1]
		right = x == board[0].size - 1 ? nil : board[y][x + 1]
		bottom = y == board.size - 1 ? nil : board[y + 1][x]
		
		cell.render drawn_row, top, left, right, bottom
	end
	drawn_row.each { |e| puts e if e.length > 0 }
end
