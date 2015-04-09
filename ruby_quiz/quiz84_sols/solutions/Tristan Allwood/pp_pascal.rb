if __FILE__ == $0
  rows = ARGV[0].to_i

  tri = Hash.new do |h,k|
    h[k] = Hash.new do |hh,kk|
      if kk == 0 or kk == k
        hh[kk] = 1
      else
        hh[kk] = h[k-1][kk] + h[k-1][kk-1]
      end
    end
  end

  tri_a = Array.new(rows) do |i|
    Array.new(i+1) do |j|
      tri[i][j]
    end
  end

  spacing = tri_a.flatten.max.to_s.size
  space = " " * spacing
  len = tri_a[-1].size

  puts tri_a.map { |row|
    pad = len - row.size
    (space * pad) + row.map { |val| "%#{spacing}d" % val }.join(space)
  }.join("\n")
end
