# WordEquations
#
# $ cat test.txt
# i
# am
# lord
# voldemort
# tom
# marvolo
# riddle
# $ cat test.txt | ruby quiz112.rb
# i + am + lord + voldemort == tom + marvolo + riddle
#
# Prints equation closest to 80 chars in length.
#
# Also:
# $ cat test.txt | ruby quiz112.rb shortest
# $ cat test.txt | ruby quiz112.rb longest
# $ cat test.txt | ruby quiz112.rb all
#
# Generates word equations by solving the equivalent
# homogenous linear equations. E.g.
#
# a = hohoho
# b = h
# c = oo
# d = ho
# ->
# h's:   3a + b +    + d = 0
# o's:   3a +     2c + d = 0
# ->
# solutions:
#  [-2, 6, 3, 0] & [-1, 0, 0, 3]
# ->
# hohoho+hohoho == h+h+h+h+h+h+oo+oo+oo
# hohoho        == ho+ho+ho

require 'homogenouslinearsolver'

class WordEquations
  def self.word_problem(words)
    words = words.map {|word| word.downcase.match(/\w+/); $&}.uniq
    words = words.select{|w| w}

    rows = ('a'..'z').map do |l|
      words.map {|word| Rational(word.count(l), 1) }
    end
    solutions = HomogenousLinearSolver.solve(Matrix[*rows])

    # if solution value is negative, add the word to the left side,
    # otherwise add to the right.
    solutions.collect do |sol|
      left_words = []
      right_words = []
      sol.each_with_index do |val, i|
        if val < 0
          left_words += [words[i]]*(val*-1)
        elsif val > 0
          right_words += [words[i]]*val
        end
      end
      left_words.join(" + ") +
        " == " + right_words.join(" + ")
    end
  end
end

if ARGV[0] == "test"
  require 'test/unit'

  class String
    def sorted
      (unpack('c*').sort).pack('c*')
    end
  end

  class TestWordEquations < Test::Unit::TestCase
    def test_hohoho
      words = %w{hohoho h oo}
      assert_equal ["hohoho + hohoho == h + h + h + h + h + h + oo + oo + oo"],
      WordEquations.word_problem(words)
    end

    def test_get_words_harry_potter
      words = %w{i am lord voldemort tom marvolo riddle}
      assert_equal ["i + am + lord + voldemort == tom + marvolo + riddle"],
      WordEquations.word_problem(words)
    end

    def test_get_words_me
      words = %w{daniel lucraft fluent radical}
      assert_equal ["daniel + lucraft == fluent + radical"],
      WordEquations.word_problem(words)
    end

    def test_get_words_evil!
      words = %w{bwu ha bwuhahahahaha}
      assert_equal ["bwu + ha + ha + ha + ha + ha == bwuhahahahaha"],
      WordEquations.word_problem(words)
    end

    def test_get_words_1
      words = %w{dormitory dirty room}
      assert_equal ["dormitory == dirty + room"],
      WordEquations.word_problem(words)
    end

    def test_get_words_2
      words = %w{statue of liberty built to stay free}
      assert_equal ["statue + of + liberty == built + to + stay + free"],
      WordEquations.word_problem(words)
    end

    def test_get_words_3
      words = %w{hohoho h oo ho}
      assert_equal ["hohoho + hohoho == h + h + h + h + h + h + oo + oo + oo",
                    "hohoho == ho + ho + ho"], WordEquations.word_problem(words)
    end

    def test_no_solutions
      words = %w{foo bar}
      assert_equal [], WordEquations.word_problem(words)
    end

    def test_long
      words = %w[My experience in Amsterdam is that cyclists ride where the hell they like and aim in a state of rage at all pedestrians while ringing their bell loudly, the concept of avoiding people being foreign to them. My dream holiday would be a ticket to Amsterdam, immunity from prosecution and a baseball bat- Terry Pratchett]
      results = WordEquations.word_problem(words).sort_by{|eq| -eq.length}
      result = results[0]
      assert_equal "my + my + my + my + my + my + my + my + my + my + my + "+
        "my + my + my + my + my + my + my + my + my + my + my + my + my + "+
        "my + my + my + my + my + my + my + my + my + my + in + in + in + "+
        "in + in + in + in + in + is + is + is + is + is + is + is + is + "+
        "is + is + is + is + is + that + that + that + that + ride + ride + "+
        "ride + ride + ride + ride + ride + ride + ride + the + the + the + "+
        "the + the + the + the + the + the + the + the + the + the + the + "+
        "the + the + the + the + the + the + the + the + the + the + the + "+
        "the + the + the + the + the + the + the + the + the + the + a + a + "+
        "a + a + a + a + a + a + a + a + a + a + a + a + a + a + a + a + a + "+
        "a + a + a + a + a + a + a + a + a + a + a + a + a + a + a + a + a + "+
        "a + a + loudly + loudly + loudly + loudly + concept + concept + "+
        "concept + concept == amsterdam + amsterdam + amsterdam + "+
        "amsterdam + amsterdam + cyclists + cyclists + hell + hell + hell + "+
        "they + they + they + they + they + they + they + they + they + "+
        "they + they + they + they + they + they + they + they + they + "+
        "they + they + they + they + they + they + they + they + they + "+
        "they + they + they + they + they + they + they + they + they + "+
        "and + and + and + and + and + and + and + and + aim + aim + aim + "+
        "aim + aim + aim + aim + aim + aim + aim + aim + aim + aim + aim + "+
        "aim + aim + aim + aim + aim + aim + aim + aim + aim + aim + "+
        "prosecution + prosecution + prosecution + prosecution",
        result
      sides = result.split("==")
      sides.map! {|side| side.delete("+").delete(" ")}
      left = sides[0]
      right = sides[1]
      assert left.sorted == right.sorted
    end
  end
else
  results = WordEquations.word_problem(STDIN.read.split).sort_by{|eq| -eq.length}
  if results == []
    exit(1)
  else
    if ARGV[0] == "longest"
      puts results.first
    elsif ARGV[0] == "shortest"
      puts results.last
    elsif ARGV[0] == "all"
      results.each {|r| puts r; puts}
    else
      puts results.sort_by{|eq| (80-eq.length).abs}.first
    end
    exit(0)
  end
end
