class DRPatternPlayer < Player
  MAX_PATTERN_LENGTH = 6

  def initialize(opponent)
    super
    @stat = {}
    @history = []
  end

  def choose
    paper = rock = scissors = 0
    (1..MAX_PATTERN_LENGTH).each do |i|
      break if i > @history.size*2
      stat = @stat[@history[0, i*2]]
      next unless stat
      p = stat[:paper]
      r = stat[:rock]
      s = stat[:scissors]
      count = (p + r + s).to_f
      sig = [p, r, s].max / count - 1.0 / 3
      f = sig * (1 - 1/count)
      p /= count
      r /= count
      s /= count
      if p > 0.4 && r > 0.4
        r += p
        p = s
        s = 0
      end
      if r > 0.4 && s > 0.4
        s += r
        r = p
        p = 0
      end
      if s > 0.4 && p > 0.4
        p += s
        s = r
        r = 0
      end
      paper += p * f
      rock += r * f
      scissors += s * f
    end
    case rand(3)
      when 0: paper += 0.2
      when 1: rock += 0.2
      when 2: scissors += 0.2
    end
    paper *= rand()
    rock *= rand()
    scissors *= rand()
    return :scissors if paper > rock && paper > scissors
    return :paper if rock > scissors
    return :rock
  end

  def result(you, them, result)
    (1..MAX_PATTERN_LENGTH).each do |i|
      break if i > @history.size*2
      key = @history[0, i*2]
      @stat[key] ||= {:paper => 0, :rock => 0, :scissors => 0}
      @stat[key][them] += 1
    end
    @history = ([you, them] + @history)[0, MAX_PATTERN_LENGTH*2]
  end
end
