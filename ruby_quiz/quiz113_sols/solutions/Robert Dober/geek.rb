# Convert a ThinkGeek t-shirt slogan (in String form) into a binary
# representation (still a String).  For example, the popular shirt "you are dumb"
# is actually printed as:
# 
#        111100111011111110101
#        110000111100101100101
#        1100100111010111011011100010
# 
#...+....|....+....2....+....|....+....|....+....5....+....|....+....|....+....8
quiz.split.map{ |w| s=""; w.each_byte{ |b| s<<b.to_s(2)}; s}.join("\n")
