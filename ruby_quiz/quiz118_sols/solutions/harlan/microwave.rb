
class Keypad
  attr_accessor :keypad, :min_seq, :sec_seq, :input
  
  def initialize
    @input = ""
    @min_seq = []
    @sec_seq = []
    @keypad = Array.new(4) { Array.new(3) }
    cnt=0
    @keypad.each_with_index do |row, i|
      row.map! { |j| j = cnt; cnt+=1 }
    end
    @keypad[3] = ['#', 0, '*']
  end
  
  def handle_input
    #@input = gets.strip!                  
    @sec_seq = @input.split('')   
    
    min = @input.to_i / 60
    sec = @input.to_i % 60
    @min_seq = ("%02d" % min.to_s + "%02d" % sec.to_s).to_i.to_s.split('')    # max seconds on input is 9999
  end
  
  def which_seq
    sec_seq_total = find_seq_total(@sec_seq.dup)
    min_seq_total = find_seq_total(@min_seq.dup)
    sec_seq_total < min_seq_total ? @sec_seq : @min_seq
  end
  
  private
  
    def find_seq_total(arr)
      tally = 0
      last = arr.shift
      arr.each do |butn|
        tally += distance(last.to_i, butn.to_i)
        last = butn
      end
      tally
    end
    
    def distance(butn1, butn2)
      i1, j1 = find_i(butn1), find_j(butn1)
      i2, j2 = find_i(butn2), find_j(butn2)
      Math.sqrt( (i2-i1)**2 + (j2-j1)**2 )
    end
  
    def find_i(butn)
      case butn
      when 1..3 then return 0
      when 4..6 then return 1
      when 7..9 then return 2
      else return 3
      end
    end
  
    def find_j(butn)
      if    [2,5,8,0].include?(butn)   then return 1
      elsif [1,4,7,'#'].include?(butn) then return 0
      elsif [3,6,9,'*'].include?(butn) then return 2
      end
    end
    
    module Microwave
      def self.microwave(sec)
        k = Keypad.new
        k.input = sec
        k.handle_input
        k.which_seq
      end
    end

end


puts Keypad::Microwave.microwave(ARGV[0])


