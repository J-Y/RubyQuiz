require 'benchmark'
include Benchmark

require 'optparse'

require 'ruby_quiz_90'

board_size = 5
benchmark = false
profile = false
iterations = 1

opts = OptionParser.new
opts.on('-sBOARDSIZE',
       '-s BOARDSIZE',	
       '--size=BOARDSIZE',
	'--size BOARDSIZE',
	'Height and width of board, default is 5x5',
	Integer)  {|val| board_size = val }
opts.on('--bench',
	'Specifies that a benchmark will be done.'
	)  { | val | benchmark = true }

opts.on('--profile',
	'Profile execution') {  profile = true}

opts.on('--iterations=COUNT',
	'--iterations COUNT',
	'COUNT specifies the number of iterations',
       'for benchmarking or profiling',
	Integer) { | val | iterations = val }

opts.on('--help',
	'produce this help text') { puts opts.to_s
		exit }
				
begin
	opts.parse(ARGV)
rescue
      puts opts.to_s
      exit
end

puts "board_size is #{board_size}x#{board_size}"
puts "benchmark=#{benchmark}, profile=#{profile}, iterations=#{iterations}"

player = nil

if benchmark
	bm(iterations) do | test |
		test.report("#{board_size}x#{board_size}:") do
		player = RubyQuiz90::Player.new(board_size)
		player.play(0,1)
		end
	end
else
	if profile
		require 'profile'
	end
	iterations.times do
		player = RubyQuiz90::Player.new(board_size)
	       	player.play(0,1)
	end
end
puts player.board
