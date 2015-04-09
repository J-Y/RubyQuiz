def search( start_word, end_word, dictionary )
  # check pre-condition
  raise "invalid argument" if start_word.nil? || 
                              end_word.nil?   ||
                              dictionary.nil? ||
                              start_word.size != end_word.size

  return [strat_word, end_word] if start_word == end_word
  return nil unless dictionary.delete(start_word)
  return nil unless dictionary.delete(end_word)

  paths = [[start_word]]
  while !paths.empty?
    new_paths = []
    paths.each do |path|
      word = path.last
      word.size.times do |i|
        ('a'..'z').each do |c|
          new_word = word.dup
          new_word[i] = c
          return (path << new_word) if new_word == end_word
          next if !dictionary.delete(new_word)
          new_paths << (path.dup << new_word)
        end
      end
    end
    paths = new_paths
  end
  nil
end

dictionary = 'words.txt'
if d_index = ARGV.index('-d')
  ARGV.delete_at(d_index)
  dictionary = ARGV.delete_at(d_index)
end
start_word = ARGV[0]
end_word = ARGV[1]

if start_word.nil? || end_word.nil? || dictionary.nil?
  puts "Usage: ruby #$0 [ -d dictionary ] start_word end_word"
  exit
end

puts "Loading dictionary..."
words = []
File.open(dictionary) { |f|
  while word = f.gets
    word.chomp!
    words << word if word.size == start_word.size
  end
}

puts "Building chain..."
result = search(start_word, end_word, words)
puts( result ? result : "No solution." )
