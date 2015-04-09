class Integer
  def d n
    (0...self).inject(0){|s,i| s+rand(n)+1}
  end
end

class Dice
  def initialize str
    @rule= str.gsub(/%/,'100').gsub(/([^\d)]|^)d/,'\1 1d')  # %->100 and bare d ->1d
    while @rule.gsub!(/([^.])d(\d+|\(.*\))/,'\1.d(\2)')          # 'dX' ->  '.d(X)'
    end                                                               
    #repeat to deal with nesting
  end
  def roll
    eval(@rule)
  end
end

d = Dice.new(ARGV[0]||'d6')
(ARGV[1] || 1).to_i.times { print "#{d.roll}  " }
puts
