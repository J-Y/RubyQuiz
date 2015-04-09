  sub_arrs = []
arr.each_index{|i| (i...arr.length).each{|i2| sub_arrs << arr[i..i2]}}
p sub_arrs.sort_by{|arr| arr.inject(0){|s,n|s+n}}.last
