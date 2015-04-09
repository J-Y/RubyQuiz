#! /usr/bin/ruby
require 'enumerator'
require 'optparse'
require 'ostruct'

class String
	# Alias for String#center that fits into the ljust, rjust naming scheme.
	def cjust(*args)
		self.center(*args)
	end
	
	# align(:r, 5) --> rjust(5).  Alignment can be :r, :l, :c
	def align(alignment, *args)
		self.send((alignment.to_s + "just").to_sym, *args)
	end
end	

class Numeric
	# Is the given number a power of self?
	# 16.isPowerOf(2) == true
	# 100.isPowerOf(2) == false
	def isPowerOf(other)
		i = 0
		while (other ** i <= self)
			return true if other ** i == self
			i += 1
		end
		false
	end
	
	def average(other)
		(self + other) / 2
	end
end

# Rounds have matches which have a winning and loosing team.
class Match
	def initialize(*teams)
		@teams = teams.sort
		setLoser
	end
	
	# The loser is defined as the team with the lowest ranking before the tournament.
	def setLoser
		@teams.last.eliminate
	end
	
	def winner
		@teams.find{|x| !x.eliminated?}
	end
	
	def loser
		@teams.find{|x| x.eliminated? }
	end
	
	# Return in the following format: <winner> vs. <looser>
	def to_s
		@teams.collect{|team| team.to_s}.join(" vs. ")
	end
	
	attr_reader :teams
end

# Tournaments have rounds, which have matches.
class Round
	@@totalRounds = 0
	
	def initialize()
		@matches = []
		@roundNum = @@totalRounds += 1
	end
	
	def addMatch(match)
		@matches.push(match)
	end

	# Prints the round in "Round x: <match>, <match>, etc." format.
	def to_s
		"Round #{@roundNum}: " + @matches.join(", ") + "."
	end
	
	# This changes the order of the matches so that in the next round, the most extreme teams will face off.
	# Assumes that the matches were previously sorted by favorability (asc or desc)
	def sort!
		sorted = []
		while @matches.length > 0
			sorted << @matches.shift << @matches.pop
		end
		@matches = sorted.compact
		self
	end
	
	attr_reader :roundNum, :matches
end

# Matches have teams which have info about themselves.
class Team
	@@favored = []
	@@currentRound = nil
	@@total = 0
	
	def initialize(name)
		@name = name
		@eliminated = false
		@rounds = []
		@@favored.push(self)
		@@total += 1
		self
	end
	
	# Remove a team from future rounds if they lost.
	def eliminate
		@eliminated = true
		@@favored.delete(self)
	end
	
	# If a team has played in a certain round.
	def inRound?()
		@rounds.include? @@currentRound
	end
	
	# Add a round a team has played in
	def addPlayedRound()
		@rounds << @@currentRound
		self
	end
	
	# Returns an array with teams not in the current round by favorability.
	def self.eligibleTeams()
		@@favored.select{|x| !x.inRound?}.sort
	end
	
	def <=>(other)
		@@favored.index(self) <=> @@favored.index(other)
	end
	
	def self.currentRound=(round)
		@@currentRound = round
	end
	
	def self.total
		@@total
	end
	
	attr_reader :name, :eliminated
	alias_method :"eliminated?", :eliminated
	alias_method :"to_s", :name
end

class Tournament
	# Recieves an aray of team names in order of ranking with the best first.
	def initialize(teams)
		@teams = teams.collect {|team| Team.new(team.to_s) }
		@rounds = []
	end
	
	def createNextRound
		currentRound = Round.new()
		Team.currentRound = currentRound
		
		# The top teams have a "bye" opponent if the number of teams isn't a power of two.  Bye opponents always lose.
		until (Team.total.isPowerOf(2))
			currentRound.addMatch( Match.new(
				Team.eligibleTeams.first.addPlayedRound,
				Team.new("bye").addPlayedRound
			) )
		end
		
		# Assign the rest of the teams to play their extreme opposites.
		while(Team.eligibleTeams.length > 1)
			currentRound.addMatch( Match.new(
				Team.eligibleTeams.last.addPlayedRound,
				Team.eligibleTeams.first.addPlayedRound
			) )
		end
		
		currentRound.sort! if currentRound.roundNum == 1
		@rounds.push(currentRound)
	end
	
	def createAllRounds
		until (@teams.find_all{|x| !x.eliminated?}.length == 1)
			createNextRound
		end
	end
	
	def to_s
		@rounds.join("\n")
	end
	
	def toASCIIChart(chartHeightModifier, spacingLeft, spacingRight, alignment)
		# Everything goes into this array in output[x][y] format, which is then printed.  The origin is in the top left.
		output = ASCIICoordinatePlane.new
		
		# This stores the midpoints of the existing games outputted so that the next round's matches will be aligned in between this round's matches.
		midpoints = Hash.new( Array.new )
		midpoints[1] = [chartHeightModifier]
		@rounds.first.matches.each {midpoints[1].unshift( midpoints[1].first - (chartHeightModifier + 2) )}
		
		x = 2
		
		# Every round is one column.
		@rounds.each do |round|
			# The longest team name.
			columnWidth = round.matches.collect{|match| match.teams}.flatten.collect{|team| team.name}.max{|a, b| a.length <=> b.length}.length + spacingRight
			
			connectTheDots = []
			insertMidpoint = true
			
			# Every iteration makes 1 match appear.
			round.matches.reverse.each do |match|
				y = midpoints[round.roundNum].shift + 2
				
				# The first team's name.
				output.set(x, y, match.teams[0].name.to_s.align(alignment, columnWidth))
				
				# The line under that team's name.
				output.fill(x - spacingLeft, y -= 1, x + columnWidth, y, "-")
				output.set(x - spacingLeft, y, "+")
				output.fill(0, y, x - 1, y, " ") if round.roundNum == 1
				
				# The connector to the next round.
				output.set(x + columnWidth + 1, y -= 1, "-" * 3)
				
				# Deals with the midpoints.
				if insertMidpoint
					midpoints[round.roundNum + 1].push(y)
				else
					midpoints[round.roundNum + 1].push( midpoints[round.roundNum + 1].pop.average(y) )
				end
				insertMidpoint = !insertMidpoint
				
				# The line above the next team's name.
				output.fill(x - spacingLeft, y -= 1, x + columnWidth, y, "-")
				output.set(x - spacingLeft, y, "+")
				output.fill(0, y, x - 1, y, " ") if round.roundNum == 1
				
				# The next team's name.
				output.set(x, y -= 1, match.teams[1].name.to_s.align(alignment, columnWidth))
				
				# The line on the right of the match going vertically.
				output.vertLine(x + columnWidth, y + 3, y+1)
				
				# To connect the match and the next match to each other.
				connectTheDots.push(y+2)
			end
			x += columnWidth + 4
			
			# Makes the lines vertically between matches.
			connectTheDots.each_slice(2) do |yvalues|
				starting = yvalues[0]
				if yvalues[1]
					ending = yvalues[1]
				else
					ending = starting
				end
				
				output.vertLine(x, starting, ending)
			end
			
			x += spacingLeft
		end
		
		# Print the winning team.
		output.set(x - spacingLeft, midpoints[@rounds.length].last, "> " + @rounds.last.matches[0].winner.name)
		output
	end
	
	attr_reader :rounds
end

# Represents a coordinate plane with the origin in the top left.  Every position can store a character.
class ASCIICoordinatePlane
	def initialize
		# Thank you Joel VanderWerf!
		@value = Hash.new {|h,k| h[k] = Hash.new {" "}}
		
		@maxx = 10
		@miny = -10
	end
	
	# Sets a specific character to a point, overflowing onto points to the right if neccessary.
	def set(x, y, string)
		0.upto(string.length-1) do |index|
			@value[x][y] = string[index].chr	
			x += 1
		end
		
		@miny = y if y < @miny
		@maxx = x if x > @maxx
	end
	
	# Fill a horizontal line with a repeating character.
	def fillHorz(opts)
		set(opts[:startx], opts[:starty], opts[:string ] * (opts[:endx] - opts[:startx]).abs)
	end
	
	# Fill a vertical line with a repeating character.
	def fillVert(opts)
		yvalues = [opts[:starty], opts[:endy]]
		y = yvalues.max
		
		until (y < yvalues.min)
			set(opts[:startx], y, opts[:string])
			y -= 1
		end
	end
	
	# Fills a straight, non-diagonal line with a repeating character
	def fill(startx, starty, endx, endy, string)
		if startx == endx
			fillVert({:startx => startx, :endx => endx, :starty => starty, :endy => endy, :string => string})
		else
			fillHorz({:startx => startx, :endx => endx, :starty => starty, :endy => endy, :string => string})
		end
	end
	
	# Creates a vertical line with +'s for the line endings.
	def vertLine(x, starty, endy)
		fill(x, starty, x, endy, "|")
		[starty, endy].each {|y| set(x, y, "+") }
	end
	
	# Outputs the coordinate plane to a string with spaces where no character was entered.
	def to_s
		output = ""
		0.downto(@miny) do |y|
			0.upto(@maxx) do |x|
				output += @value[x][y]
			end
			output += "\n"
		end
		output
	end
end

class OptParser
	def self.parse(args)
		options = OpenStruct.new
		options.csv = nil
		options.numerical = nil
		options.league = nil
		options.chart = false
		options.chartheight = 4
		options.spacingleft = 3
		options.spacingright = 1
		options.alignment = :l
		options.textual = false
		
		# When called with no options, show the help.
		args = ["-?"] if args.empty?
		
		opts = OptionParser.new do |opts|
			opts.banner = "Usage: tournie.rb [options]"
			opts.separator ""
			opts.separator "Use one of the following options to determine the teams:"
			
			# From 1 to a numerical value.
			opts.on("-n", "--numerical TEAMS",
					"TEAMS number of teams where 1 is the best",
					"and TEAMS is the worst.") do |n|
						options.numerical = n
			end
			
			# From a CSV file
			opts.on("-f", "--from-csv FILE",
					"CSV file FILE to get team data from.",
					"<rank>,<name>\\n format") do |file|
						options.csv = file
			end
			
			opts.separator ""
			opts.separator "And any number of these to determine the output format(s):"
			
			# Chart based representation
			opts.on("-c", "--[no-]chart",
					"Display an ASCII based chart of rounds") do |chartYesNoMaybeNaN|
						options.chart = chartYesNoMaybeNaN
			end
			
			# Textual representation
			opts.on("-t", "--[no-]text",
					"Display the rounds in a textual format,",
					"for example:",
					"Round 1: 1 vs. 8, 4 vs. 5...") do |text|
						options.textual = text
			end
			
			opts.separator ""
			opts.separator "The following are completely optional:"
			opts.separator "(the short names correspond with positions on the num-pad)"
			
			# Chart height modifier
			opts.on("-8", "--chart-height HEIGHT",
					"Controls the vertical spacing on the chart,",
					"with a higher HEIGHT meaning more spacing.", 
					"Defaults to 4, must be an integer above 2.") do |heigh|
						options.chartheight = heigh.to_i
			end
				
			# Spacing to the left of team names.
			opts.on("-4", "--spacing-left SPACE",
					"Controls the space to the left of the team names.",
					"Defaults to 3, must be a positive, non-negative integer.") do |s|
						options.spacingleft = s.to_i
			end
			
			# Spacing to the right of team names.
			opts.on("-6", "--spacing-right SPACE",
					"Controls the space to the right of the team names.",
					"Defaults to 1, must be a positive, non-negative integer.") do |s|
						options.spacingright = s.to_i
			end
			
			# Alignment of team names.
			opts.on("-5", "--team-alignment ALIGNMENT",
					"The alignment of team names on their lines.",
					"Defaults to [l]eft, can be [r]ight or [c]entered.",
					"Takes -6 but not -4 into account.") do |s|
						options.alignment = s.to_sym
			end
			
			opts.on("-?", "-h", "--help", "Show this message") do
				puts opts
				exit
			end
		end
		
		opts.parse!(args)
		options
	end
end

# Parse command line arguments
opts = OptParser.parse(ARGV)

# Create the tournament.
if (opts.numerical)
	tournie = Tournament.new((1..(opts.numerical.to_i)).to_a)
else
	teams = Hash.new
	orderedTeams = Array.new
	f = File.new(opts.csv)
	
	f.each_line do |line|
		line.chomp!
		line =~ /^([0-9]+), *(.*)$/
		teams[$1.to_i] = $2
	end
	
	teams.keys.sort.each do |rank|
		orderedTeams.push(teams[rank])
	end
	
	tournie = Tournament.new(orderedTeams)
end

# Do the logic
tournie.createAllRounds

# Display the tournament
puts tournie.to_s if opts.textual
puts tournie.toASCIIChart(opts.chartheight, opts.spacingleft, opts.spacingright, opts.alignment).to_s if opts.chart