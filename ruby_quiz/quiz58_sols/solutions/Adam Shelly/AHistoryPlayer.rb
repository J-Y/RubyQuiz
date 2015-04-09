require 'AdamsPlayers.rb'
require 'yaml'

HistoryFile = "ads_khist.yaml"

class WeightedAverage
	def initialize window
		@store = []
		@size = window
	end
	def add item, weight
		@store.shift if @store.size > @size
		@store << [item,weight]
		self
	end
	def ave
	  totweight = 0
		@store.inject(0){|sum,e| totweight+=e.last; sum+e.first*e.last}/(totweight.to_f)
	end
end

class AHistoryKalahPlayer <APessimisticKalahPlayer
	def initialize name
		super	
		@db = load
		@stack=[]
		@myside = nil
	end
	def reset
	  @stack=[]
		@myside = @side
		save HistoryFile
	end
	
	def get_move
		update_scores @board
	  @level=0
		scores = db_fetch(@board)
		if scores.sum !=0   																#there is data in the record
			scorez = scores.zip((0..5).to_a).sort.reverse 
			m = scorez.first.last
		end
		while m && @board[m]==0
			scorez.shift
			m = scorez.first.last if !scorez.empty?
		end
		m = best_move(@board) if !m                       
	  @stack << [@board,m,WeightedAverage.new(16).add(scores[m],2)]
		save HistoryFile if game_almost_over? simulate(@board,m)
		m
	end
	def scoreboard b
	  b[6]-b[13]
	end
	def update_scores board
		reset if @side!=@myside
		score = scoreboard board
		(1..16).each do |n|
			break if n > @stack.size
			oldboard,move,wave = @stack[-n]
			delta = score-scoreboard(oldboard)  		#did we improve or worsen our relative score?
			db_update(oldboard,move,wave.add(delta,1/Math::sqrt(n)).ave)   #record it, weighted by age
		end
	end
	def game_almost_over? board
		!board[0..5].find{|e| e>0} || board[7..12].find_all{|e| e>0}.size <1
	end
	def key board
		(board[0..5]+board[7..12]).join('-')
	end
	def db_fetch board
		@db[key(board)]||=Array.new(6){0}
	end
	def db_update board,move,score
		  a = db_fetch board
			a[move]=score
		end

	def load
		if File.exists? HistoryFile
			File.open(	HistoryFile,"rb+"){|f| YAML::load(f) } 	
		else
			{}
		end
	end
	def save name
		File.open( name, 'wb' ) {|f| f<< (@db.to_yaml)}
	end

	#I added the following lines to the bottom of KalahGame#play_game so that I could get better scoring. 
	  #>> 	top.notify_over [top_score,bottom_score] if top.respond_to? :notify_over
	  #>> 	bottom.notify_over [bottom_score, top_score] if bottom.respond_to? :notify_over
	#This player still works without these.
	def notify_over score
		final = Array.new(14){0}
		final[6]=score[0]
		final[13]=score[1]
		update_scores final
	end

end


