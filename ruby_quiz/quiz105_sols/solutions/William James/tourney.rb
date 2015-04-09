Inf = 999

def find_best x
  Array( x ).flatten.min
end

class Array
  def partition_teams
    t = sort_by{|x| find_best( x ) }
    [ t[0,t.size/2], t[t.size/2..-1].reverse ]
  end
end

num_teams = ARGV.shift.to_i

n = 1
begin n *= 2 end until n >= num_teams
teams = (1..num_teams).to_a + [Inf] * (n - num_teams)

while teams.size > 2 do
  teams = teams.partition_teams.transpose
end
f = nil
p teams.flatten.partition{f=!f}.transpose
