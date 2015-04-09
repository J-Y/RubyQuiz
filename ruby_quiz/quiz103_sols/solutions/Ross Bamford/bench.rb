require 'dm'
require 'benchmark'

words = File.read('words_en.txt').split.map { |s| s.split(' ') }.flatten
str = File.read('practical-file-system-design.txt')

rxp, ndm, dm = nil, nil, nil
iters = 10

puts "### CREATION (x#{iters}) ###"
Benchmark.bm do |x|
  if RUBY_VERSION >= "1.9"
    x.report('regexp      ') do
      iters.times { rxp = Regexp.new(words.map { |w| Regexp.escape(w) }.join('|')) }
    end
  end
  x.report('tree matcher ') do
    iters.times { dm = DictionaryMatcher.new(*words) }
  end 
end

iters = 500

puts "### MATCHING (x#{iters}) ###"
Benchmark.bm do |x|
  if RUBY_VERSION >= "1.9"
    x.report('regexp       ') do
      iters.times { rxp =~ str }
    end
  end 
  x.report('tree matcher ') do
    iters.times { dm =~ str }
  end 
end

