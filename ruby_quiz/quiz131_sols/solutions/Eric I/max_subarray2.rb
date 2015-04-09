def max_sub_array2(a)
  (1..a.size).inject([]) { |l, s| l + a.enum_cons(s).to_a }.sort_by { |b| [b.inject { |s, e| s + e }, -b.size] }.last
end
