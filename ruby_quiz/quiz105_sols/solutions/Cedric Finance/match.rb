class TournamentMatchup
  attr_reader :team_count, :round_count, :teams
  
  def initialize(team_count)
    @team_count = team_count
    @round_count = (Math.log(team_count)/Math.log(2)).ceil
    total = 2**@round_count
    @teams = []
    1.upto(team_count) { |i| teams << i }
    (total - team_count).times { teams << "bye" }
    while @teams.size > 1
      newt = []
      while not @teams.empty?
        newt << Match.new(@teams.first, @teams.last)
        @teams = teams[1..-2]
      end
      @teams = newt
    end
  end
end

class Match

  attr_reader :teams

  def initialize(team1, team2)
    @teams = [team1, team2]
  end

  def to_s
    return "["+@teams.first.to_s+","+@teams.last.to_s+"]"
  end
end

m = TournamentMatchup.new 6
puts m.teams
