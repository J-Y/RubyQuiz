#!/usr/local/bin/ruby -w

class Integer
    ONES = %w[ zero one two three four five six seven eight nine ]
    TEEN = %w[ten eleven twelve thirteen fourteen fifteen
                  sixteen seventeen eighteen nineteen ]
    TENS = %w[ zero ten twenty thirty forty fifty
                sixty seventy eighty ninety ]

    def to_en
        d, n = self.divmod(10)
        if d == 0
            ONES[n]
        elsif d == 1
            TEEN[n]
        elsif d < 10
            TENS[d] + ((n > 0) ?  ("-" + ONES[n]) : "")
        else
            raise "Class Integer#to_en only goes to 99 not #{self}"
        end
    end
end

class String
    # to_counts returns a 26 element array containing the counts of
    # each letter in the input string. e.g. "add".to_counts -> [1,0,0,2,0...]
    # Only counting lower case for speed. Be sure to downcase.
    def to_counts
        counts = Array.new(26).fill(0)
        each_byte do |b| counts[b - ?a] += 1 if b >= ?a && b <= ?z end
        counts
    end

    # similar to to_counts except adds the result into an existing array.
    def accum_counts(counts)
        each_byte do |b| counts[b - ?a] += 1 if b >= ?a && b <= ?z end
    end
end

class Array
    include Enumerable
    # Return an array of textual pangram sections from a count_array
    def pan_body()
        self.zip((?a..?z).to_a).collect do |n, c|
            sprintf(" %s%s %c%s",                   \
                (c==?z ? "and " : ""),              \
                n.to_en, c,                         \
                (n>1) ? "'s" : "")
        end
    end

    # Turn a pangram text array into a string.
    def pan_string()
        pan_body().join(',') + "."
    end
end

class CounterFactory
    # The designated initializer is called with a pangram prefix string
    # e.g. "This string contains". It sets up a pair of hash tables
    # filled with pattern counting functions and other initial values.
    def initialize(withString=nil)
        @add_word = {}
        @subtract_word = {}
        add_numbers('+', @add_word)
        add_numbers('-', @subtract_word)
        add_initial(withString) if withString != nil
        add_numbers('+', @add_word)
    end

    # add_function takes an input string and creates lambda functions which
    # transform count arrays (like those made by to_counts).
    # add_function(1, "one", "+", add_word) creates a function of arity 1
    # and adds it to the @add_word hash table with a key of 1.
    # Calling this function with a count array increments the 'o', 'n', and 'e'
    # letter counts. If the input array was initially filled with 0, then
    # the content of that array is equivalent to "one".to_counts.
    def add_function(key, aString, op, table)
        counts = aString.downcase.to_counts
        src = 'lambda { |targ| '
        counts.each_with_index do |n,i|
                src += "targ[#{i}] #{op}= #{n}; " if (n > 0)
        end
        src += '}'
        table[key] = eval(src)
    end

    # Add functions for each named number, with integer keys, to a table.
    def add_numbers(op, table)
        #add_function(0, "no", op, table)
        add_function(1, "one", op, table)
        for n in (2..99)
            add_function(n, n.to_en + "s", op, table)
        end
    end

    # Add a function mapping the constant elements of a pangram to a count array.
    def add_initial(prefix)
        # A pangram is : "prefix" + counts of each letter + "and" before 'z'
        known_string = prefix.downcase + ('a'..'z').to_a.join("") + "and"
        add_function(:initial, known_string, '+', @add_word)

        # known_count[letter] is the count of each letter we know must exist
        known_count = known_string.to_counts

        name_bytes = Array.new(26).fill(0)
        (1..99).each { |n| n.to_en.accum_counts(name_bytes) }
        in_names = name_bytes.collect {|n| n > 0}
        # Now we have an array of booleans representing whether a character
        # is constant (only appearing in the prefix or enumerated list)
        # or is a variable quantity (because it also appears in number names

        # From the count of what we initially knew to be present, return
        # our initial target. This is our best initial guess for a result
        # which will converge quickly. Basically, anything which is
        # not found in a name, is now known to occur a constant number of
        # times in the result. If it is in a name, I just punt and
        # prepare to see it 1 time like Simon does.
        @target_template = in_names.zip(known_count).collect do |in_name, known|
            if in_name
                1
            else
                known
            end
        end

        # Starting with the count of known contents add the letter counts
        # for the numbers we expect to see. The counts in the target template
        # indicate that we expect to see N occurences of that (char) in the
        # result. Thus if 7 a's are reflected in the target we must have
        # an associated set of bytes {seven's} in the result. The following
        # code initializes the result template with the static byte counts
        # that we know must occur in the result. Using the target template as
        # a guide, we then call the appropriate adder_function to increment
        # the counts for the spelled out numbers which MUST be present in
        # the result if our guess remains congruent. e.g. if the target contained
        # [7, 2, 1, 2]... we MUST increment the result_template by
        # "sevens" "twos" "one" "twos"
        @result_template = known_count.dup
        @target_template.each do |n|
            @add_word[n].call(@result_template)
        end

    end

    # Make sure these don't get clobbered so return a copy
    # Should these be dup'ed or frozen instead?
    def target_template()
        @target_template.dup
    end
    def result_template()
        @result_template.dup
    end

    # This is syntactic sugar, taking any number of arguments
    # or an array of arguments and calling all of them on a fresh array.
    def array_from_functions(*args)
        counts = Array.new(26).fill(0)
        for arg in args
            if arg.is_a?(Array)
                arg.each do |o| @add_word[o].call(counts); end
            else
                p arg
                @add_word[arg].call(counts);
            end
        end
        counts
    end

    # Easy access to the function maps
    attr_reader :add_word, :subtract_word
end

def pangram_main()
    sallowPrefix = 'This pangram tallies'
    sallowTarget = [5, 1, 1, 2, 28, 8, 6, 8, 13, 1, 1,
        3, 2, 18, 15, 2, 1, 7, 25, 22, 4, 4, 9, 2, 4, 1];
    prefix = "A pangram from jq contains one zebra,"

    # Initialize the CounterFactory and grab the maps
    cf = CounterFactory.new(prefix)
    add_word=cf.add_word
    subtract_word=cf.subtract_word

    # Set up the target and result arrays.
    # Though these will converge eventually these are not interchangeable!
    # They are complementary not equivalent. The target initially contains
    # a set of small integers. Each n refers to the expectation of finding
    # N of a particular character in the output.  Each N == 1 indicates
    # that we have no idea how many occur in the end result.
    # Any fortunate N > 1 means, we know exactly how may will be in the
    # final tally. The result_count entries contain sums for each byte
    # we know we will encounter and also the sum for the spelled out
    # numbers reflected in out target_count array.
    #
    # These two structure mirror what a pangram is.
    # The target reflects the semantic intent ->
    # It (the pangram) will have: 1 a, 2 b's...
    # The result reflects the mechanical instantiation
    # "This pangram sentence has one a, two b's..."
    target_count = cf.target_template
    result_count = cf.result_template

    delta, i, f, target, result = nil
    loopcount = 0
    different = true

    # We will loop until we converge
    while different
        if loopcount % 10000 == 0
            p "--- #{loopcount} " + Time.new.to_s
            p target_count, result_count
        end
        loopcount += 1

        # Each time through, visit and compare each target and result element
        # While they differ, we will change our guess by updating the
        # counts in the target_array. Change a guess by increasing
        # or decreasing the expected occurence of a single character.
        # Reflect that change in the result by adding and subtracting
        # multiple counts in the result corresponding to spelled out
        # numbers. For instance if target_count[i] is changed from
        # 7 to 12 we decrement the result buckets for the bytes in
        # 'sevens' and increment by the bytes in 'twelves'. The 'seve'
        # changes are a wash so we have 1 less n and one more t, w, and l
        # in the result.

        different = false

        # If the target and result differ make
        for i in (0..25)
            target = target_count[i]
            result = result_count[i]

            if target != result
                delta = rand((target - result).abs + 1)

                begin
                    subtract_word[target].call(result_count)
                    if target < result
                        target = target + delta
                    else
                        target = result + delta
                    end
                    add_word[target].call(result_count)
                    target_count[i] = target
                    different = true
                rescue
                    # I'm not sure how to handle this yet.
                    # A while ago I was getting errors with some
                    # pangram prefix strings. The calculations
                    # diverged, causing calls to nonexistent
                    # adders or subtractors: with keys 0, -1, -2...
                    # instead of fixnums between 1 and 99
                    # This usually happens only after 500K or so iterations.
                    raise
                end

            end
        end
    end

    p "solution found in #{loopcount} iterations"
    p target_count, result_count
    mypan = prefix + target_count.pan_string
    t2=(mypan.downcase).to_counts
    p "mypan" +  "--"*20
    p t2, mypan
    p t2 == target_count
end

if __FILE__ == $0
    pangram_main()
end
#[7, 2, 2, 2, 26, 8, 3, 6, 10, 2, 1, 2, 3, 15, 16, 2, 2, 10, 31, 25, 3, 5, 12, 4, 4, 2]
#panstring="A pangram from jq contains one zebra, seven a's, two b's, two c's, \
#two d's, twenty-six e's, eight f's, three g's, six h's, ten i's, two j's, one k, \
#two l's, three m's, fifteen n's, sixteen o's, two p's, two q's, ten r's, \
#thirty-one s's, twenty-five t's, three u's, five v's, twelve w's, four x's, \
#four y's, and two z's."
#true
