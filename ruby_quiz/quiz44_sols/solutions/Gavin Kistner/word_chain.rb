#!/usr/local/bin/ruby
require 'set'

class String
    LETTERS = ('a'..'z').to_a
    # Finds and returns an array that links the current word to _dest_word_,
    # where each link in the chain is a word that differs from the previous
    # only by a single character.
    #
    # The _visitation_map_ parameter is a hash containing all legal words as
    # keys, and that should be initialized with the values mapping to the
    # deepest depth allowable.
    def chain_to( dest_word, visitation_map, depth=1 )
        return nil if depth > $max_length

        # Find variations on myself which haven't been reached by a shorter path
        # and update the visitation map at the same time
        links = Set.new
        0.upto( self.length-1 ){ |i|
            old_char = self[ i ]
            LETTERS.each{ |new_char|
                if new_char != old_char
                    test_word = self.dup
                    test_word[ i ] = new_char
                    #Following returns nil if the word isn't in the dictionary
                    shortest_path = visitation_map[ test_word ]
                    if shortest_path && shortest_path > depth
                        #I've gotten to this word faster than anyone else
                        #Put my score in the high score board, and use this word again
                        visitation_map[ test_word ] = depth
                        links << test_word
                    end
                end
            }
        }

        path_from_me = nil
        if links.include?( dest_word )
            #Sweet, I have a direct route!
            path_from_me = [ self ]
        else
            links.each{ |test_word|
                path = test_word.chain_to( dest_word, visitation_map, depth + 1 )
                if path
                    total_length = depth + path.length + 1
                    #Only use the found path if it's shorter than one found already
                    if total_length <= $max_length
                        warn "Found a chain of length #{total_length}" if $DEBUG
                        path_from_me = path
                        $max_length = total_length
                    end
                end
            }
            if path_from_me
                path_from_me.unshift( self )
            end
        end
        path_from_me
    end

end

start_word = ARGV[0] || 'crave'
end_word = ARGV[1] || 'primp'
$max_length = Integer( ARGV[2] || start_word.length * 3 )
dict = ARGV[3] || '/usr/share/dict/words'
#dict = ARGV[3] || '2of12inf.txt'


desired_length = start_word.length
unless end_word.length == desired_length
    msg = "Error: '#{start_word}' and '#{end_word}' are not the same length"
    msg << "(#{start_word.length} vs. #{end_word.length})"
    raise msg
end

# Load words of the right length
avail_words = {}
File.open( dict, 'r' ){ |f|
    w = f.read.split(/[\r\n]+/)
    # No capital words, or words ending with % (12dicts)
    w.reject!{ |word| word.length != desired_length or /[^a-z]/ =~ word }
    w.each{ |word| avail_words[ word ] = $max_length }
}
avail_words[ start_word ] = 1

puts "Searching in #{avail_words.length} words with #{desired_length} letters"

unless avail_words.include?( end_word )
    raise "Error: '#{end_word}' is not included in #{dict}"
end

print "Chain between '#{start_word}' and '#{end_word}', "
puts  "no longer than #{$max_length} links:"

start_time = Time.new
if path = start_word.chain_to( end_word, avail_words )
    puts path.join( "\n" )
    puts end_word
else
    puts "(no such chain exists)"
end
end_time = Time.new
puts "--> %.2fs (after loading dictionary)\n " % [ end_time-start_time ]
