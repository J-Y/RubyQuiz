def test_solution( map_set, str )
  puts "#{map_set} solution too long (#{str.length} chars)" unless str.length <= 80
  maps = MAPS[ map_set ]
  maps.each{ |pair|
    quiz = pair[0]
    if Array===quiz
      quiz = quiz.dup
      oquiz = quiz.dup
    else
      oquiz = quiz
    end
    expected = pair[1]
    output = eval( str )
    
    unless expected==output
      puts "ERROR:
    quiz: #{oquiz.inspect};
expected: #{expected.inspect},
  actual: #{output.inspect}

"
    end
  }
end

MAPS = {
  :commify => [
    [1, "1"],
    [-1, "-1"],
    [0.001, "0.001"],
    [-0.001, "-0.001"],
    [999, "999"],
    [-999, "-999"],
    [999.1, "999.1"],
    [-999.1, "-999.1"],
    [999.12, "999.12"],
    [-999.12, "-999.12"],
    [999.123, "999.123"],
    [-999.123, "-999.123"],
    [9999, "9,999"],
    [-9999, "-9,999"],
    [9999.1, "9,999.1"],
    [-9999.1, "-9,999.1"],
    [9999.12, "9,999.12"],
    [-9999.12, "-9,999.12"],
    [9999.123, "9,999.123"],
    [-9999.123, "-9,999.123"],
    [12, "12"],
    [123, "123"],
    [1234, "1,234"],
    [12345, "12,345"],
    [123456, "123,456"],
    [1234567, "1,234,567"],
    [12345678, "12,345,678"],
    [-12, "-12"],
    [-123, "-123"],
    [-1234, "-1,234"],
    [-12345, "-12,345"],
    [-123456, "-123,456"],
    [-1234567, "-1,234,567"],
    [-12345678, "-12,345,678"]
  ],
  
  :flatten_once => [
    [ [], [] ],
    [ [1], [1] ],
    [ [1,2], [1,2] ],
    [ [1,[2]], [1,2] ],
    [ [[1],2], [1,2] ],
    [ [[1,2]], [1,2] ],
    [ [1,2,3], [1,2,3] ],
    [ [1,[2,3]], [1,2,3] ],
    [ [[1,2,3]], [1,2,3] ],
    [ [1,[2,[3]]], [1,2,[3]] ],
    [ [1,[[2],3]], [1,[2],3] ],
    [ [1,[2,[3,[4]]]], [1,2,[3,[4]]] ],
    [ [[[[[[6]]]]]], [[[[[6]]]]] ]
  ],

  :class_from_string => [
    ["File", File ],
    ["File::Stat", File::Stat ],
#    ["OpenSSL::Digest::DigestError", OpenSSL::Digest::DigestError ],
  ],

  :paragraph_wrapping => [
    [ "One\nTwo\nThree", "One\nTwo\nThree" ],
    [ "One\nTwo\nThree Four", "One\nTwo\nThree Four" ],
    [ "It's the end of the world as we know it.", "It's the end of the world as we know it." ],
    [ "It is the end of the world as we know it", "It is the end of the world as we know it" ],
    [ "It is the end of the world as we know it and I feel fine.", "It is the end of the world as we know it\nand I feel fine." ],
    [ "It's the end of the world as we know it, and I feel fine.", "It's the end of the world as we know it,\nand I feel fine." ],
    [ "It is the end of the world as we know it, and I feel fine.", "It is the end of the world as we know\nit, and I feel fine." ],
    [ "It is not the end of the world as we know it, and I feel fine.", "It is not the end of the world as we\nknow it, and I feel fine." ]
  ],

  :anagrams_excluding_original => [
    [ ["foo"], [] ],
    [ ["foo", "bar"], [] ],
    [ ["act", "bar", "cat", "rat"], ["cat"] ],
    [ ["star", "rats", "tars", "jib"], ["rats", "tars"] ],
  ],

  :anagrams_including_original => [
    [ ["foo"], ["foo"] ],
    [ ["foo", "bar"], ["foo"] ],
    [ ["act", "bar", "cat", "rat"], ["act", "cat"] ],
    [ ["star", "rats", "tars", "jib"], ["star", "rats", "tars"] ],
  ],

  :binary_string => [
    [ "you are dumb","111100111011111110101\n110000111100101100101\n1100100111010111011011100010" ],
    [ "Hello World","10010001100101110110011011001101111\n10101111101111111001011011001100100" ]
  ],
  
  :wondrous => [
    [1,  [1] ],
    [3,  [3,10,5,16,8,4,2,1] ],
    [5,  [5,16,8,4,2,1] ],
    [8,  [8,4,2,1] ],
    [15, [15,46,23,70,35,106,53,160,80,40,20,10,5,16,8,4,2,1] ],
    [31, [31,94,47,142,71,214,107,322,161,484,242,121,364,182,91,274,137,412,206,103,310,155,466,233,700,350,175,526,263,790,395,1186,593,1780,890,445,1336,668,334,167,502,251,754,377,1132,566,283,850,425,1276,638,319,958,479,1438,719,2158,1079,3238,1619,4858,2429,7288,3644,1822,911,2734,1367,4102,2051,6154,3077,9232,4616,2308,1154,577,1732,866,433,1300,650,325,976,488,244,122,61,184,92,46,23,70,35,106,53,160,80,40,20,10,5,16,8,4,2,1] ]
  ],
  
  :array_to_hash => [
    [ [1,2], {1=>2} ],
    [ [1,2,3], {1=>{2=>3}} ],
    [ %w[one two three four five], {"one" => {"two" => {"three" => {"four" => "five"}}}} ]
  ]

}

# 1 - Commify Numerics
s = 'i,f=quiz.to_s.split(".");i.gsub(/(\d)(?=\d{3}+$)/,"\\\\1,")+(f ?("."+f):"")'
test_solution :commify, s

# 2 - Flatten_Once
s = 'a=[]; quiz.each{|x| Array===x ? a.concat(x) : a<<x}; a'
test_solution :flatten_once, s

# 3 - Shuffle Array
s = 'quiz.sort_by{ rand }'

# 4 - Resolve Class from String
s1 = 'quiz.split("::").inject(Module){ |r,o| r.const_get(o) }'
test_solution :class_from_string, s1
s2 = 'eval(quiz)'
test_solution :class_from_string, s2

#5 - Paragraph Wrapping
s = 'quiz.gsub( /^(.{1,40})($|[ \t]+)/ ){ $2.empty? ? $1 : "#{$1}\n" }'
test_solution :paragraph_wrapping, s

#6 - Anagrams
s1 = 'r=quiz.shift.split("").sort;a=[];quiz.each{|w|a<<w if w.split("").sort==r};a'
test_solution :anagrams_excluding_original, s1

s2 = 'a=[];r=quiz[0].split("").sort;quiz.each{|w|a<<w if w.split("").sort==r};a'
test_solution :anagrams_including_original, s2

#7 - String to Binary String
s1 = 'quiz.split(" ").map{|s| s.scan(/./).map{|c| "%b" % c[0] }.join }.join("\n")'
test_solution :binary_string, s1

s2 = 'quiz.split(" ").map{|s| o=""; s.each_byte{|b| o << b.to_s(2) }; o }.join("\n")'
test_solution :binary_string, s2

s3 = 'o=""; quiz.each_byte{|b| o << ( b==32 ? "\n" : "%b" % b ) }; o'
test_solution :binary_string, s3

#8 - Random line
s = 'all = quiz.readlines; all[ rand(all.length) ]'

#9 - Wondrous
s = 'a=[n=quiz]; while n>1; a << ( n%2==0 ? n/=2 : n=(n*3)+1 ); end; a'
test_solution :wondrous, s

#10 - Array to Nested Hash
s1 = 'a=quiz; h={a[-2]=>a[-1]}; (a.size-3).downto(0){ |i| h={a[i]=>h} }; h'
test_solution :array_to_hash, s1

s2 = 'a=quiz; y,z=a[-2..-1]; h={y=>z}; a[0..-3].reverse.each{ |o| h={o=>h} }; h'
test_solution :array_to_hash, s2

s3 = 'a=quiz; z,y=a.pop,a.pop; h={y=>z}; a.reverse.each{ |o| h={o=>h} }; h'
test_solution :array_to_hash, s3

s4 = 'a=quiz.reverse; h=Hash[a.shift,a.shift].invert; a.each{ |o| h={o=>h} }; h'
test_solution :array_to_hash, s4