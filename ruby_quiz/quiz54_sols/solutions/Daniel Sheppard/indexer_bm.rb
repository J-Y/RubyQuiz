require 'benchmark'
require 'indexer'

# delete any existing index
files = ["words.indexer", "index.indexer"]
files.each {|x| File.delete(x) if File.exist?(x)}
ix = Indexer.new(*files)

#read Shakespeare's Sonnets
#(available from http://www.gutenberg.org/etext/1041)
started = false
file = nil
hascontent = false
open('wssnt10.txt') {|f| f.each {|line|
    next unless started || (started = /^I$/.match(line))
    if "End of The Project Gutenberg Etext of Shakespeare's Sonnets" == line.chomp
        file.close if file
        break
    end
    if line.strip.empty?
        if hascontent
            file.close if file
            file = nil
        end
    else
        if !file
            file = File.open('data/'+line.chomp+".txt", 'w')
            hascontent = false
        else
            hascontent = true
            file << line
        end
    end
}}

Dir['data/*'].each {|x| ix.record_file(x)}

def test_grep(word)
    Dir['data/*'].select { |x|
        match = false
        File.open(x) {|f| f.grep(/[^\w']#{word}[^\w']/) {match = true; break }}
        x if match
    }
end

find1, find2 = nil
Benchmark.bm(20) {|bm|
    x = 0
    ix.find_word('x')
    times = 100
    bm.report('first word') {times.times {find1 = ix.find_word('where')}}
    bm.report('median word') {times.times {find1 = ix.find_word('forbear')}}
    bm.report('last word') {times.times {find1 = ix.find_word('curious')}}
    bm.report('index last word') {times.times {ix.index_of('curious')}}
    bm.report('non-existant') {times.times {ix.find_word('fdasfasdf')}}
    bm.report('grep first ') {times.times {find2 = test_grep('where')}}
    bm.report('grep median ') {times.times {find2 = test_grep('forbear')}}
    bm.report('grep last ') {times.times {find2 = test_grep('curious')}}
} 
p find1, find2
p find1 === find2
p find1.size,find2.size
p find1.size === find2.size


