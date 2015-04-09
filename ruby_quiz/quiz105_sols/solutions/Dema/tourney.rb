# draw.rb
class Match

  # All matches have an Id, a top player/team and bottom player/team
  attr_reader :id, :top, :bottom

  def initialize(id, top, bottom)
    @id = id
    @top = top
    @bottom = bottom
  end
end

# a Draw is composed of rounds and matches
class Draw
  attr_reader :rounds
  attr_reader :matches

  # here is the generation of the match-ups
  def initialize(players)
    @matches = [] # the list of all matches
    @rounds = {} # the hash of matches for each round

    match = round = 1

    # normalize players count into square potency
    nsqrplayers = 2 ** Math.frexp(players.size - 1).last

    # derive candidates for 1st round, setting byes for top players
    candidates = (1..nsqrplayers).to_a.map { |c| c > players.size ? nil : players[c-1] }

    while (ncandidates = candidates.size) >= 2
      while !candidates.empty?
        @rounds[round] ||= []

        # setup first x last matches from the candidates list
        @rounds[round] << @matches[match] = Match.new(match,
                                                      candidates.shift,

                                                      candidates.pop)
        match += 1
      end

      # derive candidates for remaining rounds, but now
      # the candidates will appear in the form of match Ids
      # so let's map the candidates from the winners of the previous matches
      candidates = (((@rounds[round].first.id)..(@rounds[round].last.id))).to_a.map do |m|

        # was it a bye?
        @matches[m].bottom.nil? ? "#{@matches[m].top}" : "W#{m}"
      end
      round += 1
    end
  end

  def to_s
    buf = ""
    for r in @rounds.keys.sort
      buf << "R#{r}\n"
      for m in @rounds[r]
        buf << "M#{m.id}: #{m.top} x #{m.bottom.nil? ? 'bye' : m.bottom}\n"
      end
      buf << "\n"
    end
    buf
  end
end

players = (1..10).to_a
puts Draw.new(players).to_s
