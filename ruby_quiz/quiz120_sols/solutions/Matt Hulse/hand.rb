#file: hand.rb
#author: Matt Hulse - www.matt-hulse.com

class Hand
  attr_reader :right_or_left, :finger_count

  def initialize(right_or_left, count = 1)
    @right_or_left = right_or_left
    @finger_count = count
  end

  def touch(hand)
    hand.add_fingers(self.finger_count)
  end

  def add_fingers(num)
    @finger_count += num
    if @finger_count >= 5 then
      @finger_count = 0
    end
  end

  def clap(hand,num)
    hand.add_fingers(num) #num must be <= self.finger_count
    @finger_count -= num
  end

  def to_s
    result = ""
    #print left to right
    i = 0
    (1..5).each{
      i += 1
      if(i <= @finger_count) then
        result += "|"
      else
        result += "-"
      end
    }
    return result if @right_or_left == :right
    return result.reverse
  end

end
