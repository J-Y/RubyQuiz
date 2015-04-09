inf = File.open "e:\\ruby\\programs\\rubyquiz\\TWL06.txt"
contents = inf.readlines
inf.close
outf = File.open "e:\\ruby\\programs\\rubyquiz\\cropped.txt", "w"
contents.each do |x|
  x.chomp!
  next if x.length < 3 || x.length > 6
  outf.puts "#{x}"
end
outf.close