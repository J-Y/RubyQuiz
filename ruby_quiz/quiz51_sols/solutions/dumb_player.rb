#!/usr/local/bin/ruby -w

class DumbPlayer < Player
  def initialize
    super
    
    @data = ""
    
    @plays   = nil
    @discard = nil
  end
  
  def show( game_data )
    if game_data =~ /^You (?:play|discard)/
      @plays   = nil
      @discard = nil
    end
    
    @data << game_data
  end
  
  def move
    if @data.include?("Draw from?")
      draw_card
    else
      make_move
    end
  ensure
    @data = ""
  end
  
  private
  
  def draw_card
    "n"
  end
  
  def make_move
    if @plays.nil? and @data =~ /Hand:  (.+?)\s*$/
      @plays   = $1.split.map { |card| card.sub(/Inv/, "I") }
      @discard = "d#{@plays.first}"
    end
    
    if @plays.empty?
      @discard
    else
      @plays.shift
    end
  end
end
