#! /usr/bin/ruby -w
require 'arrayvalue.rb'
require 'rubygems'
require 'facet/string/bracket'

# Represents a row ("rank") on a chess board
class ChessRow < Array
	def initialize
		replace(Array.new(8))
	end
		
	# Sets the specified vacant square to the specified piece, with nthVacant starting at 0.
	def setVacantSquare(nthVacantSquare, piece)
		to_av.select{|x| x.nil?}[nthVacantSquare].set(piece)
	end
	
	def to_s
		collect{|x| x.bracket(" ")}.join("|").bracket("|")
	end
end

class Chess960Row < ChessRow
	KeRN = <<-END.split("\n").collect{|x| x.split(" ")}
	N N R K R
	N R N K R
	N R K N R
	N R K R N
	R N N K R
	R N K N R
	R N K R N
	R K N N R
	R K N R N
	R K R N N
	END
	
	def setFromNum(id)
		# Set the bishops, light first then dark.
		1.downto(0) do |x|
			self[(id % 4)*2 + x] = "B"
			id /= 4
		end
		
		# Set the queen
		setVacantSquare(id % 6, "Q")
		id /= 6
		
		# Set everything else using KeRN codes.
		KeRN[id].each do |currentPiece|
			setVacantSquare(0, currentPiece)
		end
		self
	end
end

Pawns = ChessRow.new.fill("p").to_s
EmptyRows = [ChessRow.new.fill {|i| i % 2 == 0? " " : "#" }.to_s,
			ChessRow.new.fill {|i| i % 2 == 1? " " : "#" }.to_s]
Spacer = "+---" * (Pawns.to_s.length / 4) + "+"

def parseInput(input)
	case input
		when nil
			puts "Usage:",
				"\tchess960 all - Print all the possible Chess960 lineups",
				"\tchess960 rnd - Print a random Chess960 lineup",
				"\tchess960 ID - Print ID Chess960 lineup"
		when /all/
			0.upto(959) {|x| parseInput(x) }
		when /(ra?nd)/
			parseInput(rand(960).to_i)
		else # is a number
			input = input.to_i % 960 # Change 960 into 0.
			mainRow = Chess960Row.new.setFromNum(input).to_s
			[input.to_s + ": ",
				mainRow.downcase,
				Pawns.downcase,
				EmptyRows * 2,
				Pawns.upcase,
				mainRow.upcase].
			flatten.each{|x| puts x, Spacer}
	end
end
parseInput(ARGV[0])