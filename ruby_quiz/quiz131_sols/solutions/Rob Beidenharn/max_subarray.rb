class Array
  # Given an Array of numbers, return the contiguous sub-array having the
  # maximum sum of its elements.  Longer sub-arrays are preferred.
  #
  #--
  # (or members of any Ring having operations '+' (binary, associative and
  # commutative) and '-' (unary, giving the inverse with respect to '+'))
  #++
  def sub_max identity=0
    return self if size < 2     # nothing to sum!

    ms = Array.new(size) { Array.new(size) {identity} }
    mx, range = self[0], 0..0
    0.upto(size-1) do |e|
      e.downto(0) do |s|
        current = ms[s][e] = if s == e
                               self[s]
                             else
                               ms[s][e-1] + ms[s+1][e] + (- ms[s+1][e-1])
                             end
        if current > mx || current == mx && (e - s + 1) > (range.end - range.begin + 1)
          mx = current
          range = s..e
        end
      end
    end
    self[range]
  end
end

if __FILE__ == $0
  require 'test/unit'

  class Array
    def put2d
      print '[ '
      each do |row|
        row.put1d
        print ",\n  "
      end
      puts ']'
    end

    def put1d
      print '[ '
      each do |item|
        print("%3d, " % item)
      end
      print ']'
    end
  end

  class SubMaxTest < Test::Unit::TestCase
    def test_quiz_example
      input = [-1, 2, 5, -1, 3, -2, 1]
      expected = [2, 5, -1, 3]

      assert_equal expected, input.sub_max
    end

    def test_empty
      assert_equal [], [].sub_max
    end
    def test_single
      assert_equal [ 0], [ 0].sub_max
      assert_equal [-1], [-1].sub_max
      assert_equal [ 1], [ 1].sub_max
    end
    def test_all_positive
      input = [ 1, 2, 4, 8 ]
      assert_equal input, input.sub_max
    end
    def test_all_non_negative
      input = [ 1, 2, 0, 4 ]
      assert_equal input, input.sub_max
    end
    def test_all_negative
      input = [ -1, -2, -3, -9 ]
      assert_equal [-1], input.sub_max
      input = [ -2, -1, -3, -9 ]
      assert_equal [-1], input.sub_max, 'need to test diagonal'
    end
    def test_prefer_length_earlier
      input = [ -1, 0, 1, -2, -9 ]
      assert_equal [0, 1], input.sub_max, "if actual is [1], need to add a length test on range"
    end
    def test_prefer_length_later
      input = [ -1, 1, 0, -2, -9 ]
      assert_equal [1, 0], input.sub_max, "if actual is [1], need to add a length test on range"
    end

    def test_prefer_length_multiple_options
      input = [ 1, 2, 3, -6, 6 ]
      # options
      # [6]
      # [1,2,3]
      expected = [ 1, 2, 3, -6, 6 ]
      assert_equal expected, input.sub_max, "if [6] or [1,2,3] you can do better"
    end
  end
end
