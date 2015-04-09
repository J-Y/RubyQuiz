class Dict
  #Reduces the file 'wordlist.txt' which is the list of dictionary words
  #into a file of the same words but of length no less than i
  #and no bigger than j
  def Dict.reduce(i, j)
    File.open('wordlist.txt') do |fin|
      File.open("reducedwordlist#{i}.txt", "w", File::CREAT) do |fout|
		fin.each do |input|
		  puts = "In"
		  input = input.strip
		  fout.puts input if input.length>=i && input.length<=j
		end
      end
    end
  end

  #Creates a hash of arrays, each array corresponds to words starting with a certain letter
  def Dict.get_dict(min_length)
    dict_hash = Hash.new
    File.open("reducedwordlist#{min_length}.txt", "r") do |f|
      f.each do |line|
	line  = line.strip
	dict_hash[line[0]] ||= []
	dict_hash[line[0]].push(line)
      end
    end
    return dict_hash
  end

  #Performs a binary search and returns the index of the found string
  #For example, looking for "ac" in ["ab", "acd", "ae"] we get 1
  #and looking for "ac" in ["ab", "ac", "acd"] we also get 1
  #Searching for "ac" in ["ab", "abc", "abcd"] returns 2
  def Dict.binary_search(a, b, str, array)
    return a-1 if a == array.length
    middle = (a+b)/2
    raise RuntimeError if b<a	  #This should never happen, we should always stop at b==a
    return a if b==a
    case str<=>array[middle]
    when 1
      binary_search(middle+1, b, str, array)
    when -1
      binary_search(a, middle, str, array)
    else
      middle
    end
  end
    

  #Returns 1 if the str is in the dictionary, 0 if it's a substring
  #of something in the dictionary, and -1 if it's neither
  def Dict.in_dict?(str, dict_hash)
    begin
      return 0 if str == ""
      return -1 if str.nil?
      i = binary_search(0, dict_hash[str[0]].length, str, dict_hash[str[0]])
      raise RuntimeError if i >= dict_hash[str[0]].length
      return 1 if dict_hash[str[0]][i] == str
      return 0 if dict_hash[str[0]][i][0...str.length] == str
      return -1
    rescue RuntimeError
      puts "binary_search messed up and got b<a or returned invalid index"
      exit
    end
  end
end
