# * Given a Numeric, provide a String representation with commas inserted between
# each set of three digits in front of the decimal.  For example, 1999995.99
# should become "1,999,995.99".
#...+....|....+....2....+....|....+....|....+....5....+....|....+....|....+....8
m=/[^\.]*/.match(quiz.to_s);p=$';m[0].reverse.gsub(/\d{3}\B/,'\&,').reverse+p

