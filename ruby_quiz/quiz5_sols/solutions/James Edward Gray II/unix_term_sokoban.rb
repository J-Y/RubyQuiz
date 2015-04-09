#!/usr/bin/env ruby

require "sokoban"

def draw( g )
	screen = "Level #{g.level} - #{g.moves} moves\n\n" + g.display
	screen.gsub("\n", "\r\n")
end

system "stty raw -echo"

game = Sokoban.new

loop do
	system "clear"
	puts draw(game)
	
	if game.level_solved?
		puts "\r\nLevel solved.  Nice Work!\r\n"
		sleep 3
		game.load_level

		break if game.over?
	end
	
	case STDIN.getc
		when ?Q, ?\C-c
			break
		when ?S
			game.save
		when ?L
			game = Sokoban.load if test ?e, "sokoban_saved_game.yaml"
		when ?R
			game.restart_level
		when ?U
			game.undo
		when ?j, ?j
			game.move_left
		when ?k, ?K
			game.move_right
		when ?m, ?m
			game.move_down
		when ?i, ?I
			game.move_up
	end
end

if game.over?
	system "clear"
	puts "\r\nYou've solved all the levels Puzzle Master!!!\r\n\r\n"
end

END { system "stty -raw echo" }
