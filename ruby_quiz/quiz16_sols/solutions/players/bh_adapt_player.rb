SYMBOLS = [ :rock,
           :paper,
           :scissors ]
KILLER = { :rock => :paper, :paper => :scissors, :scissors => :rock }
MAXSIZE = 5

class Symbol
  def +(o) 
    return (self.to_s+o.to_s).to_sym
  end
end

class BHAdaptPlayer4 < Player

  def initialize( opponent )
    @stats = Hash.new() 
    @lastmoves = []
  end

  def get_keys
    keys = [  ]
    @lastmoves.each do |pair|
      keys.unshift( keys.empty? ? pair : (keys[0]+pair))
    end
    keys
  end

  def choose
    info = nil
    get_keys.each do |key|
      info = @stats[key]
      break if info
    end
    if ! info
      SYMBOLS[rand(3)]
    else
      max = -1
      msym = nil
      info.keys.each do |sym|
        msym,max = sym,info[sym] if(info[sym] > max)    
      end
      KILLER[msym] 
    end
  end

  # called after each choice you make to give feedback
  # you              = your choice
  # them             = opponent's choice
  # win_lose_or_draw = :win, :lose or :draw, your result
  def result( you, them, win_lose_or_draw )
    get_keys.each do |key|
      @stats[key] = create_stat if ! @stats[key]
      @stats[key][them] += 1
    end
    @lastmoves.unshift(@lastchoice)
    @lastmoves.pop if @lastmoves.size > MAXSIZE

    @lastchoice = them+you
  end

  def create_stat
    stat = {}
    SYMBOLS.each {|sym| stat[sym] = 0 }
    stat
  end

end
