require 'set'
require 'getoptlong'

def search_words words, known
  hash= Hash.new
  words.each do |word|
    (s = word.dup).size.times do |i|
      26.times do |c| s[i] = ?a + (s[i] + 1 - ?a) % 26
        hash[s] = word if $dict.include?(s) && !known[s]
      end
    end
  end
  hash
end

def find_chain word_a, word_b
  reachable_a = (temp_a = {word_a => 0}).dup
  reachable_b = (temp_b = {word_b => 0}).dup
  found = nil

  loop do
    reachable_a.merge!(temp_a = search_words(temp_a.keys, reachable_a))
    break if found=temp_a.inject(nil){|r, w|reachable_b[w[0]]? w[0]:r}
    warn "reachable a: #{reachable_a.size}" if $verbose

    reachable_b.merge!(temp_b = search_words(temp_b.keys, reachable_b))
    break if found=temp_b.inject(nil){|r, w|reachable_a[w[0]]? w[0]:r}
    warn "reachable b: #{reachable_b.size}" if $verbose

    if temp_a.size == 0 || temp_b.size == 0
      puts "now way!";
      exit 0
    end
  end

  word, list = found, [found]
  while (word = reachable_a[word]) && word != 0
    list.insert(0, word)
  end
  word = found
  while (word = reachable_b[word]) && word != 0
    list.push(word)
  end
  list
end

def usage
  puts "#{$PROGRAM_NAME} [-v|--verbose] [-h|--help]"+
    "[-d|--dictionary] {word1} {word2}"
  exit
end

opts = GetoptLong.new(
  [ "--dictionary", "-d", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--verbose", "-v", GetoptLong::NO_ARGUMENT ],
  [ "--help", "-h", GetoptLong::NO_ARGUMENT ])

$verbose, dictfile = nil, 'words.txt'
opts.each do |opt, arg|
  usage if opt == "--help"
  $verbose = true if opt == "--verbose"
  if opt == "--dictionary"
    dictfile = arg
    usage if dictfile.empty?
  end
end
usage if ARGV.size != 2

$dict = Set.new
open(dictfile){|f| f.each{|w|$dict << w.chomp}}

puts find_chain(ARGV[0], ARGV[1])
