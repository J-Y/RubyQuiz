#!/usr/bin/ruby

# Solution to the {word filter quiz}[http://ruby.brian-schroeder.de/quiz/detect_words/]. This unit is the main executable that
# executes a number of tests for the different implementations and displays the
# results. See TestRecursive, TestOptimal and TestInterleaved for the
# implementations.
#
# Brian Schröder

require 'word_filter'
require 'detect_words_recursive.rb'
require 'detect_words_saving.rb'
require 'detect_words_optimal.rb'
require 'detect_words_interleaved.rb'

# Time an event. Returns the time used and the result of the block
# e.g.
#   used_time, result = *time do 2 ** 1000 end
def time
  start = Time.new.to_f
  result = yield
  return Time.new.to_f - start, result
end

english = File.read('dict').split
svenska  = File.read('/usr/share/dict/svenska').split

methods = [['Division-02',        TestRecursive.method(:find_words)],
  ['Division-03',        lambda do | filter, words | TestRecursive.find_words_n(filter, words, 3) end],
  ['Division-04',        lambda do | filter, words | TestRecursive.find_words_n(filter, words, 4) end],
  ['Division-06',        lambda do | filter, words | TestRecursive.find_words_n(filter, words, 6) end],

  ['Saving Division-02', TestSaving.method(:find_words)],
  ['Saving Division-03', lambda do | filter, words | TestSaving.find_words_n(filter, words, 3) end],
  ['Saving Division-04', lambda do | filter, words | TestSaving.find_words_n(filter, words, 4) end],
  ['Saving Division-06', lambda do | filter, words | TestSaving.find_words_n(filter, words, 6) end],

  ['Optimal for 0.01%',  lambda do | filter, words | TestOptimal.find_words(filter, words, 0.0001) end],
  ['Optimal for 0.1%',   lambda do | filter, words | TestOptimal.find_words(filter, words, 0.0010) end],
  ['Optimal for 0.7%',   lambda do | filter, words | TestOptimal.find_words(filter, words, 0.0070) end],
  ['Optimal for 1%',     lambda do | filter, words | TestOptimal.find_words(filter, words, 0.0100) end],
  ['Optimal for 10%',    lambda do | filter, words | TestOptimal.find_words(filter, words, 0.1000) end],

  #['Division-08',        lambda do | filter, words | TestRecursive.find_words_n(filter, words, 8) end],
  #['Division-16',        lambda do | filter, words | TestRecursive.find_words_n(filter, words, 16) end],
  #['Interleaved-02',   TestInterleaved.method(:find_words)],
  #['Interleaved-03', lambda do | filter, words | TestInterleaved.find_words(filter, words, 3) end],
  #['Interleaved-04', lambda do | filter, words | TestInterleaved.find_words(filter, words, 4) end],
  #['Interleaved-06', lambda do | filter, words | TestInterleaved.find_words(filter, words, 6) end],
  #['Interleaved-08', lambda do | filter, words | TestInterleaved.find_words(filter, words, 8) end],
  #['Interleaved-16', lambda do | filter, words | TestInterleaved.find_words(filter, words, 16) end]
  ]
STDOUT.sync = true

class TestResult
  attr_accessor :tests, :words, :banned, :duration
  def initialize(tests, words, banned, duration)
    @tests, @words, @banned, @duration = tests, words, banned, duration
  end

  # Test test_method on banned and words and output some information about its performance.
  def TestResult.new_from_test(banned, words, &test_method)
    print "Testing with #{words.length} words and #{banned.length} banned words. "
    
    filter = LanguageFilter.new(banned)
    duration, found = *time do test_method.call(filter, words) end
    
    puts "Used #{filter.clean_calls} tests. Duration %0.4f seconds" % duration
    
    unless filter.verify(found)
      puts "\nDid not pass. Difference is:"
      puts "  - found but not banned: #{(found - banned).sort.join(' ')}"
      puts "  - banned but not found: #{(banned - found).sort.join(' ')}"
      puts "Banned were #{banned.sort.join(' ')}"
    end
    
    TestResult.new(filter.clean_calls, words.length, banned.length, duration)
  end
end

class AveragedTestResult < TestResult
  attr_accessor :tests_stddev
  def initialize(tests, words, banned, duration, std_dev)
    super(tests, words, banned, duration)
    @tests_stddev = std_dev
  end
end

class TestResults
  def initialize
    @results = {}
  end
  
  def add(title, result)
    (@results[title] ||= []) << result
  end

  def each
    @results.each do | title, runs |
      avg_tests = runs.inject(0) { | r, run | r + run.tests }.to_f / runs.length.to_f
      avg_words = runs.inject(0) { | r, run | r + run.words }.to_f / runs.length.to_f
      avg_banned = runs.inject(0) { | r, run | r + run.banned }.to_f / runs.length.to_f
      avg_duration = runs.inject(0) { | r, run | r + run.duration }.to_f / runs.length.to_f
      std_dev = (runs.inject(0.0) { | r, run | r + (run.tests.to_f - avg_tests) ** 2 } / runs.length.to_f) ** 0.5
      yield title, AveragedTestResult.new(avg_tests, avg_words, avg_banned, avg_duration, std_dev)
    end
  end
end

# Format a table row
def make_line(cols, width)
  cols.zip(width).map{ |col, width| col.to_s.ljust(width)}.join(' | ')
end

# Format a title
def make_title(title, underchar)
  [title, underchar * title.length]
end

def draw_averaged_results(results)
  puts make_title('Averaged results', '=')
  width = [20, 7, 7, 8, 10, 9, 10, 40]

  tables = {}

  max_tests = Hash.new(0)
  # Hackish restructuring of test results to display it in tabular form
  results.to_a.sort.each do | method_title, results_per_method |
    results_per_method.each do | test_title, result |
      (tables[test_title] ||= {})[method_title] = result
      max_tests[test_title] = result.tests if result.tests > max_tests[test_title]
    end
  end
  
  tables.sort.each do | test_title, table |
    puts make_title(make_line([test_title, 'words', 'banned', 'ratio', 'mails used', 'std. dev.', 'duration', 'mails used'], width), '-')      
    table.sort.each do | method_title, result |
      puts make_line([method_title, "%7d" % result.words, "%7d" % result.banned, "%7.3f%%" % (result.banned / result.words * 100.0),
                       "%10.2f" % result.tests, "%9.2f" % result.tests_stddev, "%9.4fs" % result.duration,
                       '#' * (40 * result.tests / max_tests[test_title])],
                     width)
    end
    puts
  end
end

results = {}
3.times do  
  [["Debug Test", 1, 10],
    ["Small test", 3, 30],      
    ["JEGII's Fedehandschuh", 29, 3930],
    ['Larger wordbase (1)', 3, 30000],
    ['Larger wordbase (2)', 10, 30000],
    ['Larger wordbase (3)', 30, 30000],
    ['Larger wordbase (4)', 300, 30000],
    ['Larger wordbase (5)', 3000, 30000]][1..6].each do | test_title, banned_count, words_count |
    
    puts make_title(test_title, '=')
    
    words = english.sort_by{rand}[0...words_count]
    banned = words.sort_by{rand}[0...banned_count]
    
    methods.each do | method_title, method |
      GC.start
      puts '', make_title(method_title, '-')
      (results[method_title] ||= TestResults.new).
        add(test_title, TestResult.new_from_test(banned, words, &method))
    end
    puts '', '', ''
    draw_averaged_results(results)
    puts '', '', ''
  end
end

