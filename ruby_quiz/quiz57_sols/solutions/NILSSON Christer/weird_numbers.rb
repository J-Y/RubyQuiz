def divisors(n) (1..n.div(2)).collect {|i| i if n.modulo(i)==0}.compact end
def sum(arr) arr.inject(0) {|sum,element| sum+element} end

def subset?(n, divisors)
  arr=[]
  divisors.each do |i|
    arr.concat arr.collect {|j| i+j}
    arr << i
    arr.uniq!
    return true if arr.member?(n)
  end
  false
end

def weird(n)
  return if n.modulo(2)==1
  coll = divisors(n)
  diff = sum(coll)-n
  return if diff <= 0
  return n unless subset?(diff,coll)
end

def all_weird(n) (1..n).collect {|i| weird(i)}.compact end

require 'test/unit'
class TestWeird < Test::Unit::TestCase
  def test_all
    assert_equal [1,2,3,4,6], divisors(12)
    assert_equal [1,2,5,7,10,14,35], divisors(70)
    assert_equal 16, sum(divisors(12))
    assert_equal 74, sum(divisors(70))
    assert_equal true, subset?(12,divisors(12))
    assert_equal false, subset?(70,divisors(70))
    assert_equal false, subset?(4,divisors(70))
    assert_equal nil, weird(2)
    assert_equal nil, weird(12)
    assert_equal nil, weird(20)
    assert_equal 70, weird(70)
    assert_equal [70], all_weird(70) # 0.821 sec
    #assert_equal [70,836], all_weird(836) # 225 secs
  end
end
