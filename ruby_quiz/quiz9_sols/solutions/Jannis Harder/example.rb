require 'RQ9'
class YourAlgorithm < RQ9Algorithm
    def run()
        out = []
        @words.each do |word|
            out << word if ! @filter.clean? word
        end
        out
    end
end

configs = []



configs << RQ9TestRunConfiguration.new(3000,3,10,true) # words,banned,tests,change banned words every test
configs << RQ9TestRunConfiguration.new(3000,80,10,true)
configs << RQ9TestRunConfiguration.new(3000,300,10,true)
configs << RQ9TestRunConfiguration.new(30000,12,10,true)
configs << RQ9TestRunConfiguration.new(30000,200,10,true)
configs << RQ9TestRunConfiguration.new(30000,500,10,true)
configs << RQ9TestRunConfiguration.new(30000,2000,10,true)

algorithmTest = RQ9AlgorithmTest.new
algorithmTest.readWordList("dict") 

configs.each do |config|
    puts "Test: #{config.to_s}"
    puts algorithmTest.testAlgorithm(config,YourAlgorithm.new).ext_to_s # to_s
end