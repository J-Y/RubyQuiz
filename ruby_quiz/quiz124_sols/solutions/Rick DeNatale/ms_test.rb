require 'magic_square'
require 'test/unit'

class TestMagicSquare < Test::Unit::TestCase

 def test_negative_n
   assert_raise(ArgumentError) { MagicSquare.new(-1)}
 end

 def test_2
   assert_raise(ArgumentError) { MagicSquare.new(2)}
 end

 def test_to_ten
   try(1)
   for i in (3..10)
     try(i)
   end
 end

 private
 def try(n)
   m = nil
   assert_nothing_raised { m = MagicSquare.new(n)}
   assert(m.is_magic?)
 end

end
