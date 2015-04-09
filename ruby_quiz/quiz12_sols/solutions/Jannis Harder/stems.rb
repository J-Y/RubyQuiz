#Usage: <Dictionary> <Stemsize> <Cutoff>

#On my machine:
#8728 stems
#13969 possible bingos
#1141 stems have more than 6 bingos
#stemsize is 6
#bingosize is 7
#brute force needs 3169957232 comparisons
#I need 226928 hash lookups
#22.270484 sec (searching bingos)
#6.235895 sec (reading dictionary)
#28.506379 sec (total)
#0.00326608375343721 sec / stem

stemsize = (ARGV[1] || 6).to_i
minbingos = (ARGV[2] || 6).to_i

alphabeth=("a".."z").to_a;
stems = []
bingowords = []

results = {}

start1 = Time.new
File.foreach(File.expand_path(ARGV[0]||"~/dict")) do |line|
    chomped = line.chomp.downcase
    stems << chomped if chomped.size == stemsize
    bingowords << chomped if chomped.size == stemsize+1
end

start2 = Time.new

sbingos = bingowords.map{|word| word.split("").sort.join}
sbingohash={}

sbingos.each_index do |index|
    sbingohash[sbingos[index]]=bingowords[index]
end



stems.each do |stem|

    bingosfound = [];
    xbingo = stem.split("")
    alphabeth.each do |char|
        stbingo = (xbingo+[char]).sort.join
        fbingo = sbingohash[stbingo];
        bingosfound << fbingo if fbingo
    end


    if bingosfound.size >= minbingos
        results[stem] = bingosfound

    end

end
out =""
results.to_a.sort_by{|e|-(e[1].size)}.each do |result|
    out << "#{result[0]} #{result[1].size} #{result[1].join","}\n"
end
done = Time.new;

puts "\nOrdered:\n\n"
puts out
puts "#{stems.size} stems\n#{bingowords.size} possible bingos\n#{results.size} stems have more than #{minbingos} bingos"
puts "stemsize is #{stemsize}\nbingosize is #{stemsize+1}"
puts "brute force needs #{stems.size*alphabeth.size*bingowords.size} comparisons"
puts "I need #{stems.size*alphabeth.size} hash lookups"
puts "#{(done-start2).to_s} sec (searching bingos)"
puts "#{(start2-start1).to_s} sec (reading dictionary)"
puts "#{(done-start1).to_s} sec (total)"
puts "#{((done-start1).to_f/stems.size).to_s} sec / stem"
