def search( start_word, end_word, dictionary )
  # check pre-condition
  raise "invalid argument" if start_word.nil? || 
                              end_word.nil?   ||
                              dictionary.nil? ||
                              start_word.size != end_word.size

  return [strat_word, end_word] if start_word == end_word
  return nil unless dictionary.delete(start_word)
  return nil unless dictionary.delete(end_word)
  word_length = start_word.length

  start_paths = [[start_word]]
  end_paths = [[end_word]]
  paths = start_paths
  last_new_words = [end_word]
  loop do
    new_paths = []
    new_words = []
    paths.each do |path|
      word = path.last
      word_length.times do |i|
        ('a'..'z').each do |c|
          new_word = word.dup
          new_word[i] = c
          if index = last_new_words.index(new_word)
            if paths == start_paths
              return path.push(*end_paths[index].reverse)
            else
              return start_paths[index].push(*path.reverse)
            end
          end
          next unless dictionary.delete(new_word)          
          new_paths << (path.dup << new_word)
          new_words << new_word
        end
      end
    end

    return nil if new_paths.empty?

    if paths == start_paths
      start_paths = new_paths
      paths = end_paths
    else
      end_paths = new_paths
      paths = start_paths
    end
    last_new_words = new_words
  end
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
