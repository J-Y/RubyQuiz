#!/usr/bin/env ruby -rubygems

%w(hpricot open-uri).each(&method(:require))

fields, genres = (Hpricot(open("http://www.rubyquiz.com/quiz136.html")) / "p.example").map{|e| e.inner_html}
fields = fields.split
genres = genres.split "<br />"

values = IO.read(ARGV.first)[-128..-1].unpack("A3 A30 A30 A30 A4 A30 A")

unless values.first == 'TAG'
  puts "No ID3 tag found"
  exit 1
end

fields.zip(values).each do |field, value|
  case field # this feels dirty
  when 'TAG': # nada
  when 'genre': puts "#{field}: #{genres[value[0]]}"
  when 'comment'
    puts "#{field}: #{value}"
    if value[28].to_i.zero? && !value[29].to_i.zero? # ID3v1.1
      puts "track: #{value[29]}"
    end
  else puts "#{field}: #{value}"
  end
end
