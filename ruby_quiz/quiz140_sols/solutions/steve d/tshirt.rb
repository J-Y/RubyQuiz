require 'rubygems'
require 'text'
require 'yaml'

begin
  require 'inline'
  $inline = true
rescue LoadError
  $inline = false
end


module Enumerable
  def min_items(n = 1)
    self.sort[0, n]
  end

  def sum_with(start)
    inject(start) { |s, v| s + v }
  end
end

module TShirtReader
  METAPHONES = Marshal.load(File.read('metaphones.dat'))
  PRONUNCIATIONS = Marshal.load(File.read('pronunciations.dat'))
  PRONUNCIATIONS_SEARCH = Marshal.load(File.read('pronunciations_search.dat'))

  NUMBER_SPELLINGS = {
    '0' => 'zero',
    '1' => 'one',
    '2' => 'two',
    '3' => 'three',
    '4' => 'four',
    '5' => 'five',
    '6' => 'six',
    '7' => 'seven',
    '8' => 'eight',
    '9' => 'nine',
    '10' => 'ten',
    '11' => 'eleven',
    '12' => 'twelve',
    '13' => 'thirteen',
    '14' => 'fourteen',
    '15' => 'fifteen',
    '16' => 'sixteen',
    '17' => 'seventeen',
    '18' => 'eighteen',
    '19' => 'nineteen',
    '20' => 'twenty',
    '30' => 'thirty',
    '40' => 'forty',
    '50' => 'fifty',
  }

  NUMBER_SOUNDS = {
    '1' => 'won',
    '2' => 'to',
    '3' => 'three',
    '4' => 'for',
    '5' => 'five',
    '6' => 'six',
    '7' => 'seven',
    '8' => 'ate',
    '9' => 'nine',
    '10' => 'ten'
  }

  LETTER_SOUNDS = {
    'b' => 'bee',
    'c' => 'cee',
    'd' => 'dee',
    'f' => 'ef',
    'g' => 'gee',
    'h' => 'aitch',
    'j' => 'jay',
    'k' => 'kay',
    'l' => 'el',
    'm' => 'em',
    'n' => 'en',
    'p' => 'pee',
    'q' => 'cue',
    'r' => 'ar',
    's' => 'ess',
    't' => 'tee',
    'v' => 'vee',
    'w' => 'double u',
    'x' => 'ex',
    'y' => 'why',
    'z' => 'zee',
  }

  class << self
    def read(words)
      metaphone_matches = read_with_metaphones(words)
      pronunciation_matches = read_with_pronunciations(words)

      matches = (metaphone_matches[0, 5] + pronunciation_matches[0, 5]).uniq

      # sort matches based on first word
      words.map! { |w| w =~ /^\d+$/ ? (NUMBER_SOUNDS[w] || w) : w }
      #matches.sort_by {|m| (words.first[0,1] <=> m[0,1]).abs }
      matches
    end

    private

    def read_with_pronunciations(words)
      words.map! {|w| w =~ /^(\d+)$/ ? (NUMBER_SPELLINGS[$1] || w) : w }

      shirt_pronunciation = words.map {|w| PRONUNCIATIONS[w.downcase] }
      return []  if shirt_pronunciation.include? nil  # one of the words had no pronunciation
      shirt_pronunciation = shirt_pronunciation.join ' '

      distances = Hash.new{|h,k| h[k] = []}

      PRONUNCIATIONS_SEARCH.keys.each do |pronunciation|
        distance = levenshtein_distance(pronunciation, shirt_pronunciation)

        distances[distance] << pronunciation
      end

      closest_distances = distances.keys.min_items(2)
      closest_matches = closest_distances.map { |d| distances[d].map {|p| PRONUNCIATIONS_SEARCH[p] }.sum_with([]) }.sum_with([])

      words = words.join
      closest_matches = closest_matches.map {|match| match.gsub(/\(\d+\)$/,'')}.uniq
      closest_matches.sort_by do |word|
        levenshtein_distance word, words
      end
    end

    def read_with_metaphones(words)
      words.map! { |w| w.size > 1 ? w : (LETTER_SOUNDS[w] || w) }
      words = words.join(' ').gsub(/\d+/) {|d| NUMBER_SOUNDS[d] }

      shirt_metaphone = Text::Metaphone.metaphone(words).delete(' ')

      # if no exact matches, find matches with shortest levenshtein distance
      if ! (closest_matches = METAPHONES[shirt_metaphone])
        distances = Hash.new{|h,k| h[k] = []}

        min = 100
        METAPHONES.keys.each do |metaphone|
          distance = levenshtein_distance(metaphone, shirt_metaphone)

          if distance <= min
            distances[distance] += METAPHONES[metaphone]
            min = distance
          end
        end

        closest_matches = distances[distances.keys.min]
      end

      words.delete! ' '
      closest_matches.sort_by do |word|
        levenshtein_distance word, words
      end
    end

    if $inline
      inline(:C) do |builder|
        builder.c "
          int levenshtein_distance(VALUE r_s1, VALUE r_s2) {
            char *s1, *s2;
            int i, j, k, m, n;

            s1 = StringValuePtr(r_s1);
            s2 = StringValuePtr(r_s2);

            m = strlen(s1);
            n = strlen(s2);

            int d[m+1][n+1];

            for (i = 0; i <= m; i++)  d[i][0] = i;
            for (j = 0; j <= n; j++)  d[0][j] = j;

            for (i = 1; i <= m; i++) {
              for (j = 1; j <= n; j++) {
                int cost, tmp[3], min;

                if (s1[i-1] == s2[j-1])  cost = 0;
                else                     cost = 1;

                tmp[0] = d[i-1][j] + 1;
                tmp[1] = d[i][j-1] + 1;
                tmp[2] = d[i-1][j-1] + cost;

                for (k = 1, min = tmp[0]; k < 3; k++)
                  if (tmp[k] < min)
                    min = tmp[k];

                d[i][j] = min;
              }
            }

            return d[m][n];
          }
        "
      end
    else
      def levenshtein_distance(s1, s2)
        Text::Levenshtein.distance(s1, s2)
      end
    end
  end
end

if $0 == __FILE__
  p TShirtReader.read(ARGV)
end