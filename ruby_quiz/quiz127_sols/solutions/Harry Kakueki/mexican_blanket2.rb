# My HTML version prints a blanket in color.
# It is quick and dirty HTML that could certainly
# be improved but it is viewable.
# This makes a 200x100 blanket.
# It looks like this http://www.kakueki.com/ruby/q127.html

# Code Start
outs = File.new("./q127.html","w")
colors = "GWRBYRGRRGRYBRWG"
ahash = {}
ahash.store("G","<font color=\"#00ff00\">"+"o" + "</font>")
ahash.store("W","<font color=\"#ffffff\">"+"o" + "</font>")
ahash.store("R","<font color=\"#ff0000\">"+"o" + "</font>")
ahash.store("B","<font color=\"#0000ff\">"+"o" + "</font>")
ahash.store("Y","<font color=\"#ffff00\">"+"o" + "</font>")

unp = "aXaXaXaXaa"
 (1...colors.length).each do
   (1..4).each {|y| unp<<"X"<<"Xa"*(5-y)<<"a"<<"Xa"*y}
 unp << "a"
 end
row = colors.unpack(unp)
row.map! {|x| ahash[x] }
outs.puts "<html><body bgcolor=\"#dddddd\">"

 200.times do
 outs.print row[0..99].join
 outs.print "<br>\n"
 row.shift
 end

outs.puts "</body></html>"
outs.close
