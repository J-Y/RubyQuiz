# check for unintended effects on other classes
class Test3 < Test::Unit::TestCase
 def setup
   @foo_class = Class.new {
     abbrev :start
     def start; nil end
   }
   @bar_class = Class.new {
     def start; nil end
   }
 end

 def test1
   f = @foo_class.new
   b = @bar_class.new
   assert_raise NoMethodError do
      b.send(:sta)
   end
 end
end
