# RubyQuiz #128 - Verbal Arithmetic
# solution by Bob Showalter

class Array

  # Yields each permutation of k elements of the array
  # (from Raf Coremans http://pastie.caboo.se/71186)
  def each_permutation( k, array_so_far = [], &blk)
    raise 'Permutation cannot contain more elements than source array' if k > size
    if 0 == k
      yield array_so_far
    else
      each_with_index do |element, i|
        (self[0...i] + self[i+1..-1]).each_permutation( k - 1, array_so_far + [element], &blk)
      end
    end
  end
end

# get the expression like "send + more = money". allowed operators are
# +, -, and *.
words = ARGV.first or abort "Expected input expression"
words = words.downcase.gsub(/\s+/, '')
words.match(/^[a-z]+(?:[+*-][a-z]+)*=[a-z]+$/) or abort "Invalid input expression format"
words.sub!('=', '==')
letters = words.scan(/[a-z]/).uniq.join
abort "Expression has more than 10 unique letters" if letters.size > 10

# brute force search; report first solution
("0".."9").to_a.each_permutation(letters.size) do |digits|
  expr = words.tr(letters, digits.join)
  next if expr.match(/\b0/)
  if eval(expr)
    letters.split(//).zip(digits).each { |l, n| puts "#{l} => #{n}" }
    break
  end
end