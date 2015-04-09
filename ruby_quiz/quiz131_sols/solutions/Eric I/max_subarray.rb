def max_sub_array(a)
  (0...a.size).inject([]) { |c, s| c + (s...a.size).map { |e| a.slice(s..e) } }.sort_by { |b| [b.inject { |s, e| s + e }, - b.size] }.last
end
