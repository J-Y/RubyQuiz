code_key = { ".-" => "a", "-..." => "b", "-.-." => "c", "-.." => "d",
             "." => "e", "..-." => "f", "--." => "g", "...." => "h",
             ".." => "i", ".---" => "j", "-.-" => "k", ".-.." => "l",
             "--" => "m", "-." => "n", "---" => "o", ".--." => "p",
             "--.-" => "q", ".-." => "r", "..." => "s", "-" => "t",
             "..-" => "u", "...-" => "v", ".--" => "w", "-..-" => "x",
             "-.--" => "y", "--.." => "z" }

WORDS = []

def recurse(ck, a)
  naa = []
  a.each do |arr|
    4.times do |n|
      if parse_chars(arr[2], ck, n+1)
        na = [arr[0] + ck.fetch(arr[2][0,n+1]), arr[1] \
                     + arr[2][0,n+1] + "|", arr[2][n+1..-1]]
        if na[2] == "" or na[2] == nil
          WORDS << "#{na[0]} => #{na[1][0..-2]}" if not \
                     WORDS.include?("#{na[0]} => #{na[1][0..-2]}")
        else
          if not naa.include?(na)
            naa << na
          end
        end
      end
    end
  end
  naa
end

def main(w, ck)
  wlen = w.length - 1
  wa = []
  wa << [ck.fetch(w[0,1]), w[0,1] + "|", w[1..-1]] if parse_chars(w, ck, 1)
  wa << [ck.fetch(w[0,2]), w[0,2] + "|", w[2..-1]] if parse_chars(w, ck, 2)
  wa << [ck.fetch(w[0,3]), w[0,3] + "|", w[3..-1]] if parse_chars(w, ck, 3)
  wa << [ck.fetch(w[0,4]), w[0,4] + "|", w[4..-1]] if parse_chars(w, ck, 4)
  wlen.times do |i|
    wa = recurse(ck, wa)
  end
end

def parse_chars(w, ck, n)
  if ck.has_key?(w[0,n])
    true
  else
    false
  end
end

word_array = main(ARGV[0], code_key)

if ARGV[1] == "--dict"
  a = IO.readlines("/usr/share/dict/words")
  WORDS.each do |w|
    if a.include?(w[0, w.index(' ')] + "\n")
      puts w
      WORDS.delete(w)
    end
  end
  puts
end

puts WORDS.sort
