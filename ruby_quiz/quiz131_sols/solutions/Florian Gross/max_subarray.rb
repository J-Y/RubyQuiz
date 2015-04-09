class Array
  def each_cont_sub_array()
    return enum_for(__method__) unless block_given?

    0.upto(size - 1) do |start|
      1.upto(size - start) do |length|
        yield self[start, length]
      end
    end
  end
end

[-1, 2, 5, -1, 3, -2, 1].each_cont_sub_array.max_by { |ary| ary.inject(&:+) } # => [2, 5, -1, 3]
