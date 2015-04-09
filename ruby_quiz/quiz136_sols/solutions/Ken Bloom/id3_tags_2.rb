#!/usr/bin/env ruby -rubygems

%w(hpricot open-uri).each(&method(:require))

fields, genres = (Hpricot(open("http://www.rubyquiz.com/quiz136.html")) / "p.example").map{|e| e.inner_html}
fields = fields.split
genres = genres.split "<br />"

unpacktypes=Hash.new("A30")
unpacktypes["TAG"]="A3"
unpacktypes["year"]="A4"
unpacktypes["genre"]="c"
unpackstr=fields.map{|x| unpacktypes[x]}.join

id3=Hash.new
raw=open('/home/bloom/scratch/music/rondo.mp3') do |f|
  f.seek(f.lstat.size-128)
  f.read
end

values=raw.unpack(unpackstr)

fields.zip(values).each do |field,value|
  id3[field]=value
end

fail if id3["TAG"]!="TAG"

if id3["comment"].length==30 and id3["comment"][-2]==0
  id3["track"]=id3["comment"][-1]
  id3["comment"]=id3["comment"][0..-2].strip
end

id3["genre"]=genres[id3["genre"]] || "Unknown"
p id3
