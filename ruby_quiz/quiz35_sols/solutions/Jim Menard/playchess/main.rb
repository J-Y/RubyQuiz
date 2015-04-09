require 'chessgame'
require 'displaylistener'

game = ChessGame.new(DisplayListener.new)
game.play
