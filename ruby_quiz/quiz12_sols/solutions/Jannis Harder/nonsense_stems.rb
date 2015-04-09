#Usage <Dict> <Stemsize> <Cutoff>

#6.965449 sec
#13969 bingos
#43953 stems found (without cutoff)
#202 stems found (with cutoff)
#0.000158474939139535 sec/stem
#6310 stems/sec
#0.000498636194430525 sec/bingo
#2005 bingos/sec



dict = ARGV[0]||"~/dict"
stemsize = (ARGV[1] || 6).to_i
cutoff = (ARGV[1] || 10).to_i
bingosize = stemsize+1
stems = {}
bingos = []
bingocount = 0
start = Time.new
File.foreach(File.expand_path(dict)) do |bingo|
    bingo.chomp!
    if bingo.size == bingosize
        bingocount+=1
        sbingo = bingo.split("").sort.join
        subingo = sbingo.split("").uniq
        subingo.each do |char|
            stem = sbingo.dup
            stem[sbingo.index(char),1]=""
            if stems[stem]
                stems[stem][char]=1
            else
                stems[stem]={char=>1}
            end
        end
    end
end
stems = stems.to_a
stemsize = stems.size
stems.delete_if{|x| x[1].size < cutoff}
stems.sort_by{|x|-x[1].size}.each do |stem|
    puts "#{stem[0]} #{stem[1].size} #{stem[1].keys.join}"
end
done = Time.new
puts "STATS",
"#{(done-start).to_f} sec",
"#{bingocount} bingos",
"#{stemsize} stems found (without cutoff)",
"#{stems.size} stems found (with cutoff)",
"#{((done-start).to_f)/stemsize} sec/stem",
"#{(stemsize/((done-start).to_f)).to_i} stems/sec",
"#{((done-start).to_f)/bingocount} sec/bingo",
"#{(bingocount/((done-start).to_f)).to_i} bingos/sec"
