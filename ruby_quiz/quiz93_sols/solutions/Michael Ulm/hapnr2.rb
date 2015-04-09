# hapnr.rb
#
# some functions etc. concerning happy numbers


class HappyNum
  def initialize(base)
    @base = base
    @base_square = base * base
  end

  def mapper(val)
    result = 0
    while val > 0
      result += (val % @base) ** 2
      val /= @base
    end

    result
  end

  # check if the base is happy
  def happy_base?
    # odd numbers are never happy bases
    return false if (@base % 2 == 1)

    2.upto(@base_square - 1) do |nr|
      history = {}
      current_nr = nr
      while current_nr != 1
        return false if history[current_nr]
        history[current_nr] = true
        current_nr = mapper(current_nr)
      end
    end
    return true
  end
end

if $0 == __FILE__
  # puts HappyNum.new(ARGV[0].to_i).compute_cycles
  2.step(ARGV[0].to_i, 2) {|base| puts(base) if HappyNum.new(base).happy_base?}
end
