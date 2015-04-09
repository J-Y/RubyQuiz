class Morse
  MORSE_CODES           = %w{.- -... -.-. -.. . ..-. --. .... .. .--- -.- .-.. -- -. --- .--. --.- .-. ... - ..- ...- .-- -..- -.-- --..}.zip(("a".."z").to_a)

  DICTIONARY_WORDS      = File.open("/usr/share/dict/words"){|f| f.read}.downcase.split(/[^a-z]/)       rescue nil

  def parse(sequence)
    real_words(find_words(sequence.gsub(/\s+/, "")))
  end

  private

  def find_words(sequence, word="", results=[])
    if sequence.empty?
      results << word
    else
      MORSE_CODES.each do |seq, chr|
        if sequence.index(seq) == 0
          find_words(sequence[seq.length..-1], word+chr, results)
        end
      end
    end

    results
  end

  def real_words(words)
    words & DICTIONARY_WORDS rescue words
  end
end

puts(
  $stdin.read.split(/\r*\n+/).collect do |sequence|
    list        = Morse.new.parse(sequence)

    case list.length
    when 0      then    "?"
    when 1      then    list[0]
    else                "(#{list.join("|")})"
    end
  end.join(" ")
)
