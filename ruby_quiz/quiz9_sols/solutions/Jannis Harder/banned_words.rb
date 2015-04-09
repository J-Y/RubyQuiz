class JannisHardersAlgorithm < RQ9Algorithm
    def initialize()
        @steps =   [110000,700000,300000,200000,110000,
                    70000,30000,20000,11000,7000,
                    3000,2000,1100,700,300,200,110,
                    70,30,20,11,7,3,2,1]
    end
    def run()
        wordsLeft = @words.dup

        @steps.each do |count|
            if count*6 > @words.length
                next
            end

            position = 0
            while position < wordsLeft.length
                testMail = wordsLeft[position .. position+count-1].join(" ")
                if @filter.clean? testMail
                    (position .. position+count-1).each do |i|
                        wordsLeft[i]=nil
                    end
                end
                position += count
            end
            wordsLeft.compact! # delete nil words
            wordsLeft = wordsLeft.sort_by{rand}  #shuffle
        end
        wordsLeft
    end
end
