def down(x)
  return [] if x==0
  return [1] if x==1
  return [2,1] if x==2
  return [x] + down(x*2) if x.modulo(2)==1
  return [x] + down(x/2) if x.modulo(4)==0
  [x] + down(x-2)
end

def up(x)
  return [] if x==0
  return [1] if x==1
  return [2,1] if x==2
  return [x] + up(x*2) if x.modulo(2)==1
  return [x] + up(x/2) if x.modulo(4)==0
  [x] + up(x+2)
end

require 'test/unit'
class TestIlmari < Test::Unit::TestCase
  def t (actual, expect)
    assert_equal expect, actual
  end
  def test_all
    t up(255), [255, 510, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1]
    t down(257), [257, 514, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1]
    #t up(72), [72,36,18,20,10,12,6,8,4,2,1]
    #t down(28), [28,14,12,6,4,2,1]
    #t up(150128850109293).size,82
    #t down(8591982807778218492).size, 100
  end
end
