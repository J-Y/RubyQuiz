require "test/unit"
require "fgenerator"

class TestGenerator < Test::Unit::TestCase
  class C
    def value=(x)
      @value = x
    end
    def each
      loop do
        yield @value
      end
    end
  end

  def test_realtime
    c = C.new
    g = FGenerator.new(c)
    3.times do |i|
      c.value = i
      assert_equal(i, g.next())
    end
  end
end
