include Math
require 'rational'

class Tournament
  
  attr_reader :participants, :levels, :total_matchups, :tree, :stringed, :string
 
  def initialize(h)  
    # parameter checking:
    case h
    when Fixnum
      raise TypeError, "The number of participants must be > 1" unless h>1
      @participants = ("#{1}".."#{h}").to_a
    when Array
      raise TypeError, "The number of participants must be > 1" unless h.length > 1
      @participants = h.map {|x| x.to_s}
    else
      raise TypeError, "Parameter must be an Array or a Fixnum"
    end 
    
    # basic initialization
    @p_number = @participants.length
    @levels = @p_number.log2
    @levels = (1<<(@levels) == @p_number) ? @levels -1 : @levels
    @total_matchups = 1<<(@levels)
    (@p_number..(2*@total_matchups - 1)).each do |x| @participants<<nil end
    
    # setup the whole valuation tree: We already know there is ONE match at least
    @tree = [[1,2]]
    (0..@levels).each do |level|
      k = (1<<level) - 1
      nodes = @tree[-(k+1)/2,(k+1)/2].inject([]) {|s,e| s+e}
      # this counter is probably spurious in Ruby?
      i = 0
      nodes.each do |index|
        opponent = ((2*(k+1)-index+1) > @p_number) ? nil : (2*(k+1) - index+1)
        # hack to get the tree look "symmetrical" in the 1st and 2nd players
        if i < k
          @tree<< [index, opponent]
        else  
          @tree << [opponent, index]
        end 
        i += 1
      end 
    end 
  end 
  
  # pairings (i.e. with NUMBERS) (possibly with nil opponent) **after** k rounds
  def pairings(k = 0)
    return [] unless k < (@levels + 1)
    @tree[( ((1<<(@levels - k)) - 1)..((1<<(@levels - k+1)) - 2) )]
  end 
    
  # **expected** true **matches** (i.e. with names) **after** k rounds.
  # If there are tails, parinings [1,nil] give NO matches. This is "reality"
  def matches(k = 0)
    return [] unless k < (@levels + 1)
    pairings(k).find_all {|x| not(x.member?(nil))}.inject([]) do |s,e|
      pair = []
      e.each do |team|
        if team.nil? then pair<<nil else pair<<@participants[team-1] end
      end 
      s<<pair
    end 
  end 
  
  # to_s: build up a quite nice string detailing the tournament matches
  # extremely hackish!
  def to_s
    return @string unless @string.nil?
    @string = ""
    height = 4 * @total_matchups
    label = "-" * (@participants.map {|x| (x.nil? && 0) || x.length}).inject(1) {|s,e| s > e ? s : e}
    width = (label.length)*(@levels + 1) + 2*@levels
    @stringed = Array.new(height) { Array.new(width).fill(" ") }
    # step 0 is special: put all the labels
    (0..(@total_matchups-1)).each do |item|
      put_label(0,4*item,@participants[(pairings()[item][0]||0) - 1].to_s,label.length)
      put_label(0,4*(item)+2,@participants[(pairings()[item][1]||0) - 1].to_s,label.length)
    end
    # iterative steps
    (0..(@levels+1)).each do |level|
      step = (1<<level) - 1
      (0..( (1<<(@levels - level)) - 1) ).each do |pair| 
        join_pair(level,pair,step,label.length)
        put_label((level+1)*(label.length+1),2.rpower(level) + 2.rpower(level+2)*pair+step,label)
      end 
    end 
    @stringed.each {|x| @string += (x.join("") + "\n") }
    return @string
  end 

  # private methods. Used by to_s, mainly
  private  
  
  def join_pair(level,pair,step,width)
    horizontal = ((level+1) * (width + 1))
    start = 4*pair*(1<<level)+step
    end_ = start + (1<<(level+1))
    (start..end_).each do |y|
      @stringed[y][horizontal-1]= "|"
    end 
  end 

  def put_label(x,y,label,max_length = label.length)
    (0..(label.length-1)).each do |i|
      @stringed[y][max_length - label.length + x + i] = label[i].chr 
    end 
  end 
  
end 
  

class Fixnum
  
  # Too used not to have it
  def log2
    i = 0
    value = self
    while(value > 1) 
      value >>= 1
      i += 1
    end 
    i
  end 
  
end 
