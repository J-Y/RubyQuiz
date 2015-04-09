class DiscardPlayer < Player
  def initialize
    @data = ""
    super
  end

  def show( game_data )
    @data << game_data
  end

  def move
    if @data.include?("Draw from?")
      "n"
    else
      if @data =~ /Hand:  (.+?)\s*$/
        "d#{$1.split.first.sub(/nv/,"")}"
      end
    end
  ensure
    @data = ""
  end
end
