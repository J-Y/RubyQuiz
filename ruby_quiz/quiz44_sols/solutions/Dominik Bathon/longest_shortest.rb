require "word_chain"

class WordSteps
    # builds a longest shortest chain starting with word and returns it as
    # array of symbols
    # if the found chain is shorter than old_max, then it is possible to
    # determine other words, whose longest shortest chain will also be not
    # longer than old_max, those words will be added to not_longer, that way
    # the caller can avoid searching a longest chain for them
    def longest_word_chain(word, not_longer = {}, old_max = 0)
        # build chain with simple breadth first search until no more steps are
        # possible, one of the last steps is then a longest shortest chain
        current = [word.to_sym]
        pre = { current[0] => nil } # will contain the predecessors
        target = nil
        iterations = []
        loop do
            next_step = []
            iterations << current
            current.each do |csym|
                each_possible_step(csym.to_s) do |ssym|
                    unless pre.has_key? ssym
                        pre[ssym] = csym
                        next_step << ssym
                    end
                end
            end
            if next_step.empty?
                target = current[0]
                break
            else
                current = next_step
            end
        end

        # build the chain (in reverse order)
        chain = [target]
        chain << target while target = pre[target]

        # add words to not_longer if possible (see above)
        if chain.size < old_max
            (0...([old_max+1-chain.size, iterations.size].min)).each do |i|
                iterations[i].each { |w| not_longer[w] = true }
            end
        end
        chain.reverse
    end
end



if $0 == __FILE__
    dictionary = DEFAULT_DICTIONARY

    # parse arguments
    if ARGV[0] == "-d"
        ARGV.shift
        dictionary = ARGV.shift
    end
    word_length = [ARGV.shift.to_i, 1].max

    # read dictionary
    warn "Loading dictionary..." if $DEBUG
    word_steps = WordSteps.load_from_file(dictionary, word_length)

    # search chain
    warn "Searching longest chain..." if $DEBUG
    max = 0
    chain = nil
    not_longer = {}
    word_steps.each_word { |w|
        next if not_longer[w.to_sym]
        cur = word_steps.longest_word_chain(w, not_longer, max)
        if cur.size > max
            chain = cur
            max = cur.size
            warn chain.inspect if $DEBUG
        end
    }

    # print result
    puts chain || "No chain found!"
end
