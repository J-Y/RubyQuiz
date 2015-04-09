require 'test/unit'

class DaysToString
  Table= {'mon' => 1,'tue' => 2,'wed' => 3,'thu' => 4,
          'fri' => 5,'sat' => 6,'sun' => 7,
          'monday'=>1,'tuesday'=>2,'wednesday'=>3,'thursday'=>4,
          'friday'=>5,'saturaday'=>6,'sunday'=> 7,
          1 => 1, 2 => 2, 3 => 3,4 => 4, 5 => 5,6 => 6, 7 => 7}
  Days=['Mon','Tue','Wed','Thu','Fri','Sat','Sun',]
  def initialize *arg
    arg.map! do |a|
      a.downcase! if a.respond_to?(:downcase!)
      raise(ArgumentError,"Wrong Format.") if !Table.include?(a)
      a = Table[a]
    end
    arg.sort!.uniq!
    @data = arg
  end

  def to_s
    temp =[]
    txt = ""
    loop do
     x=@data.shift
     if ((x.is_a?(NilClass) && !temp.empty?) || (!temp.empty? && temp.last!=x-1))
       txt+= "#{Days[temp.first-1]}"
       txt+= ",#{Days[temp[1]-1]}" if temp.length==2
       txt+= "-#{Days[temp.last-1]}" if temp.length>2
       txt+= ','
       temp.clear
       break if x.is_a?(NilClass)
     end
      temp.push(x)
    end
    txt
  end
end

class TestDaysToString < Test::Unit::TestCase
  def test_all
    assert_raise(ArgumentError) {DaysToString.new(1,2,'tester',4,5,7).to_s}
    assert_raise(ArgumentError) {DaysToString.new(8).to_s}
    assert_raise(ArgumentError) {DaysToString.new('wacky_day').to_s}
    assert_equal("Mon-Wed,Fri-Sun,",DaysToString.new(1,2,3,5,6,7).to_s)  
    assert_equal("Mon-Sun,",DaysToString.new(1,2,3,4,4,5,4,6,7,1).to_s)
    assert_equal("Tue-Thu,",DaysToString.new(2,3,4).to_s)
    assert_equal("Fri,",DaysToString.new(5).to_s)
    assert_equal("Mon,Sat,Sun,",DaysToString.new('sun','mOnDaY',6).to_s)
    assert_equal("Tue,Thu-Sun,",DaysToString.new(4,5,6,7,2).to_s)
    assert_equal("Tue,Thu-Sun,",DaysToString.new(4,5,6,7,2).to_s)
  end
end
