
# by JEG2

#
# A simple class for managing a filter that prevents to use
# of a given _banned_words_ list.
#
class RQ9LanguageFilter
    #
    # Create a new LanguageFilter object that will
    # disallow _banned_words_.
    # Accepts a list of words, arrays of words,
    # or a combination of the two.
    #
    def initialize( *banned_words )
        @banned_words = banned_words.flatten.sort
        @clean_calls = 0
    end

    # A count of the calls to <i>clean?</i>.
    attr_reader :clean_calls

    #
    # Test if provided _text_ is allowable by this filter.
    # Returns *false* if _text_ contains _banned_words_,
    # *true* if it does not.
    #
    def clean?( text )
        @clean_calls += 1
        @banned_words.each do |word|
            return false if text =~ /\b#{word}\b/
        end
        true
    end

    #
    # Verify a _suspect_words_ list against the actual
    # _banned_words_ list.
    # Returns *false* if the two lists are not identical or
    # *true* if the lists do match.
    # Accepts a list of words, arrays of words,
    # or a combination of the two.
    #
    def verify( *suspect_words )
        suspect_words.flatten.sort == @banned_words
    end
end

#end by JEG2

#by Jannis Harder
class RQ9AlgorithmTest
    attr_accessor :words
    def initialize
        @words=[]
    end
    
    def readWordList(wordFile)
        words = IO.readlines(wordFile).map do |line|
            line.chomp
        end
        @words+= words
    end
    
    
        
    def testAlgorithm(configuration,algorithm)

        bannedWords=[]

        words = @words[0 .. configuration.words-1]

        if !configuration.rebuildBannedWords
            bannedWords = words.sort_by{rand}[0 .. configuration.bannedWords-1]
        end
        
        result = RQ9TestResult.new(configuration.words,configuration.bannedWords,
                    configuration.rebuildBannedWords)
        
        
        configuration.runs.times do 

            if configuration.rebuildBannedWords
                bannedWords = words.sort_by{rand}[0 .. configuration.bannedWords-1]
            end
        
            
            result.addRun testRun(words,bannedWords,algorithm)
            
        end
        result
    end
    

    
    
    def testRun(words,bannedWords,algorithm)
        algorithm.words = words
        filter = RQ9LanguageFilter.new bannedWords
        algorithm.filter = filter
        startTime = Time.now
        resultWords = algorithm.run
        endTime = Time.now
        
        result = RQ9TestRunResult.new(words.size,bannedWords.size,filter.verify(resultWords),endTime-startTime,filter.clean_calls)
        
    end
    


end

class RQ9TestRunConfiguration
    attr_accessor :words, :bannedWords, :runs,                #...
                        :rebuildBannedWords
    def initialize(words = 3000, bannedWords = 30, runs = 10,               #...
                         rebuildBannedWords = true)
        @words              = words
        @bannedWords        = bannedWords
        @runs               = runs
        @rebuildBannedWords = rebuildBannedWords 
    end
    
    def to_s
        "(#{@words},#{@bannedWords},#{@runs},#{@rebuildBannedWords})"
    end
end

class RQ9TestRunResult
    attr_reader :words, :bannedWords, :verified, :seconds, :mails
    def initialize(words, bannedWords, verified, seconds, mails)
        @words          = words
        @bannedWords    = bannedWords
        @verified        = verified
        @seconds        = seconds
        @mails          = mails
    end
    def to_s
        "Words:         #{@words}\n"+
        "Banned Words:  #{@bannedWords}\n"+
        "Seconds:       #{@seconds}\n"+
        "Mails:         #{@mails}\n"+
        (@verified ? "Verified\n" : "Failed\n")
    end
end

class RQ9TestResult
    attr_reader :words, :bannedWords, :runcount,            #...
                    :rebuildBannedWords, :verified,                 #...
                    :averageSeconds, :averageMails
    def initialize(words, bannedWords, rebuildBannedWords)
        @words              = words
        @bannedWords        = bannedWords
        @rebuildBannedWords = rebuildBannedWords
        @verified     = 0
        @averageSeconds     = 0
        @averageMails       = 0
        @runs               = []
    end
    
    def addRun(run)
        @runs << run
        @verified     = 0
        @averageSeconds     = 0
        @averageMails       = 0
        @runs.each do |run|
            @verified += 1 if run.verified
            @averageSeconds += run.seconds
            @averageMails += run.mails
        end
        @averageSeconds /= @runs.size
        @averageMails /= @runs.size
    end
    
    def to_s
        "Runs:          #{@runs.size}\n"+
        "Words:         #{@words}\n"+
        "Banned Words:  #{@bannedWords}\n"+
        "Average\n" +
        "  Seconds:     #{@averageSeconds}\n"+
        "  Mails:       #{@averageMails}\n"+
        "Verified:      #{@verified}/#{@runs.size}\n"+
        (@rebuildBannedWords ? "Rebuilt Banned Words\n":"")
    end
    
    def ext_to_s
        
        @runs.map { |run| run.to_s }.join("\n") + "\n\n" +
        to_s
    end
    
end

class RQ9Algorithm
    attr_accessor :words, :filter
    def run() end # return bannedWords
end






