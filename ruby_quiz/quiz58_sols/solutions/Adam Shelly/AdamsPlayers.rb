
#Adapter class - rotates the board so that player's Kalah is always 6
class KalahPlayer < Player
	def choose_move
	  n = (@side==KalahGame::TOP) ? 7 : 0
		@board = @game.board
		@board = @board.rotate n
		return get_move + n
	end
	
	#simulate a move
	def simulate board,i
		b = board.dup
		stones,b[i]=b[i],0
		while stones > 0
			i = 0 if (i+=1) >12
			b[i]+=1
			stones-=1
		end
		if (0..5)===i and b[i]==1
			b[6]+= (b[i]+b[opposite(i)])
			b[i]=b[opposite(i)]=0
		end
		b
	end
	def opposite n
		12-n
	end
	
end

#Some helpers in Array
class Array
	def rotate n
		a =dup
		n.times do a << a.shift end
		a
	end
	def sum
		inject(0){|s,e|s+=e}
	end
	#choose randomly between all items with given value
	def random_index value
		n=rand(find_all{|e|e==value}.size)
		each_with_index{|e,i| return i if e==value and (n-=1)<0 }
	end
end

#### Some simple players for testing:
class RemoveRightKalahPlayer < KalahPlayer
	def get_move
			5.downto(0) {|i| return i if @board[i]>0 }
	end
end
class RemoveHighKalahPlayer < KalahPlayer
	def get_move
			myboard = @board[0,6]
			myboard.index(myboard.max)
	end
end
class RemoveRandomHighKalahPlayer < KalahPlayer
	def get_move
			myboard = @board[0,6]
			myboard.random_index(myboard.max)
	end
end
class RemoveLowKalahPlayer < KalahPlayer
	def get_move
			myboard = @board[0,6].select{|e| e>0}
			@board[0,6].index(myboard.min)
	end
end
class RemoveRandomLowKalahPlayer < KalahPlayer
	def get_move
			myboard = @board[0,6].select{|e| e>0}
			@board[0,6].random_index(myboard.min)
	end
end

class ScoreKalahPlayer < KalahPlayer
	def get_move
		possible_scores = (0..5).map{|i| score_for i}
		possible_scores.index(possible_scores.max)
	end
	def score_for i
	  return -1 if @board[i] == 0
		simulate(@board,i)[6]-@board[6]
	end
end


### Some better players

#Tries to find the biggest increase in score for a turn
class DeepScoreKalahPlayer < KalahPlayer
	def get_move
		best_move(@board)
	end
	def best_move board
		possible_scores = (0..5).map{|i| score_for(board,i)}
		possible_scores.index(possible_scores.max)
	end
	
	#find the increase in score if we make move m
	def score_for board,m
		return -100 if board[m]<1  						  #flag invalid move
	  b, taketurn  = board,true
		while taketurn
			taketurn =  ((b[m]+m)%14 == 6)  #will we land in kalah?
			b = simulate b,m                               
			m = best_move(b) if taketurn             
		end
		b[6]-board[6]                                 #how many points did we gain?
	end
	
end


#Tries to find the biggest increase in score for a turn
#subtracts opponent's possible score
class APessimisticKalahPlayer < DeepScoreKalahPlayer
	MaxDepth = 3
	def get_move
	  @level=0
		best_move(@board)
	end
	def best_move board
		return super(board) if (@level > MaxDepth)
		@level+=1
		possible_scores = (0..5).map{|i| 
			score_for(board,i) - worst_case(simulate(board,i)) 
		}
		@level-=1
		possible_scores.random_index(possible_scores.max)
	end
	#biggest score the opponent can get on this board
	def worst_case board
		worst = 0
		opp_board = board.rotate 7
		6.times {|i|
				s = score_for(opp_board, i)
				worst = s if worst < s
			}
			worst
	end
end



