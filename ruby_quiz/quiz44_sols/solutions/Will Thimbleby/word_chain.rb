require 'set'

#read in every word into a hash
def read_dictionary(filename, length)
    words = IO.readlines(filename).collect{ |l| l.strip.downcase }.reject{ |word| word.length != length }

    Set.new(words)
end

#computes all possible neighbours of a word
def get_neighbours(word)
    allneigbours = Set.new

    for i in 0...word.length
        for c in 97..122
            neighbour = word.dup
            neighbour[i] = c
            allneigbours.add(neighbour)
        end
    end

    allneigbours
end

#performs the word chain search
def compute(a, b, dict)
    raise "words are different lengths" if a.length != b.length

    #setup
    dictionary = read_dictionary(dict, a.length)

    raise b+" not in dictionary" if !dictionary.include?(b)

    queue = [ [a] ]
    seen = Set.new([a])

    #very simple breadth first search
    while queue.length > 0
        solution = queue.delete_at(0)

        break if solution.last == b

        #get neighbours
        neighbours = get_neighbours(solution.last)
        neighbours &= dictionary
        neighbours -= seen

        seen += neighbours

        #add onto queue
        neighbours.each_with_index { |obj, i|
            queue.push( solution.dup.push(obj) )
        }
    end

    raise "cannot create word chain" if solution.last != b

    puts solution
end

#parse options very simply
dict = "/usr/share/dict/words"

a = ARGV.shift

if a == "-d"
    dict = ARGV.shift
    a = ARGV.shift
end

b = ARGV.shift

#do it
compute(a, b, dict)
