def make_change(a, list = [25, 10, 5, 1])
 # to pass testcases :-P
 return nil if a < 0
 return nil if a != a.floor
 parents = Array.new(a + 1)
 parents[0] = 0
 worklist = [0]
 while parents[a].nil? && !worklist.empty? do
   base = worklist.shift
   list.each do |coin|
     tot = base + coin
     if tot <= a && parents[tot].nil?
       parents[tot] = base
       worklist << tot
     end
   end
 end
 return nil if parents[a].nil?
 result = []
 while a > 0 do
   parent = parents[a]
   result << a - parent
   a = parent
 end
 result.sort!.reverse!
end

require 'test/unit'
N = 40
class TestMakeChange < Test::Unit::TestCase
 def test_no_solution
   N.times{
     assert_equal( nil, make_change( -1 ) )
     assert_equal( nil, make_change( 1, [] ) )
     assert_equal( nil, make_change( 1.5, [2, 1] ) )
     assert_equal( nil, make_change( 1, [2] ) )
     assert_equal( nil, make_change( 7, [5, 3] ) )
     # 1023 instead of 127 is too slow :(
     assert_equal( nil, make_change( 127, (1..10).map{ |n| 2**n } ) )
   }
 end
 def test_no_change
   N.times{
     assert_equal( [], make_change(0) )
   }
 end
 def test_one_coin
   N.times{
     a = [*(1..100)]
     for i in a
       assert_equal( [i], make_change(i, a) )
     end
   }
 end
 def test_ones
   N.times{
     a = [*(1..100)]
     for i in a
       assert_equal( [1]*i, make_change( i, [1]+a[i..-1] ) )
     end
   }
 end
 def test_two_middles
   N.times{
     for i in 1..100
       b = i*10
       m = b/2+1
       assert_equal( [m, m], make_change( m*2, [b, m, 1]) )
     end
   }
 end
 def test_first_and_last
   N.times{
     for i in 1..10
       b = i*100
       assert_equal( [b, 1], make_change( b+1, (1..b).to_a) )
     end
   }
 end
 def test_binary
   N.times{
     a = (0..7).map{ |n| 2**n }.reverse!
     for i in 0..255
       bits = a.inject([i]){ |r,x|
         r[0]<x ? r : [ r[0]-x, *(r[1..-1]<<x) ]
       }[1..-1]
       assert_equal( bits, make_change( i, a ) )
     end
   }
 end
 def test_primes
   N.times{
     a = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
     a.reverse!
     for i in 1..a.size
       v = a[0,i].inject(){|r,n|r+n}
       r = make_change( v, a )
       assert( r.size <= i )
     end
     for i in 1..a.size/2
       assert_equal( 2, make_change( a[i]+a[-i], a ).size )
     end
     # by tho_mica_l
     assert_equal( [97]*46 + [89, 7, 5], make_change( 4563, a ) )
   }
 end
 def test_misc
   N.times{
     assert_equal( [25, 10, 1, 1, 1, 1], make_change( 39 ) )
     assert_equal( [9, 2], make_change( 11, [10, 9, 2] ) )
     assert_equal( [5, 2, 2, 2], make_change( 11, [10, 5, 2] ) )
     assert_equal( [8]*3, make_change( 24, [10, 8, 5, 1] ) )
     assert_equal( [9]*3, make_change( 27, [10, 9, 5, 1] ) )
     #
     for i in 1..8
       assert_equal( [9]*i, make_change( 9*i, [10,9,1] ) )
       assert_equal( [10]+[9]*i, make_change( 10+9*i, [10,9,1] ) )
     end
   }
 end
end
