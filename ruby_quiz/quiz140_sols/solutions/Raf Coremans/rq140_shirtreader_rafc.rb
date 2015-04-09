#!/usr/bin/ruby -w

# rq140_shirtreader_rafc.rb
# Solution to http://rubyquiz.com/quiz140.html
# By Raf Coremans
#
# Usage example:
#./rq140_shirtreader_rafc.rb e scent shells
#   => essentials


require 'yaml'

require 'rubygems'
require 'text' #gem install Text


class String

  SPELL_DIGIT = Hash[
    *('0'..'9').zip(
      %w{OH ONE TWO THREE FOUR FIVE SIX SEVEN ATE NINE}
    ).flatten
  ]
  SPELL_LETTER = Hash[
    *('A'..'Z').zip(
      %w{AY BEE SEE DEE EE EFF GEE AYCH EYE JAY KAY ELL EM EN
         OH PEE CUE ARE ESS TEA YOU VEE DOUBLEYOU EX WHY ZEE}
    ).flatten
  ]

  #"Bacon! And eggs 4U" => "BACONANDEGGSFOURYOU"
  def to_normalized
    upcase.
    scan( /[\w\d\s]/).join.
    split( //).map{ |e| SPELL_DIGIT.has_key?( e) ? SPELL_DIGIT[e] + ' ' : e}.join.
    split.map{ |e| SPELL_LETTER[e] || e}.join
  end

  #"BACONANDEGGSFOURYOU" => "BKNNTKSFRY". http://en.wikipedia.org/wiki/Metaphone
  def to_metaphone
    Text::Metaphone.metaphone( to_normalized)
  end

end


module TShirtReader

  DICT = '/usr/share/dict/words'

  DICT_METAPHONE = begin
    file = 'dict_methaphone.yaml'
    File.open( file, 'r'){ |f| YAML::load( f)}
  rescue Errno::ENOENT
    words = File.readlines( DICT)
    words_by_metaphone = words.inject( Hash.new{ |h,k| h[k]=[]}) do |h, word|
      word.chomp!
      h[word.to_metaphone] << word
      h
    end
    File.open( file, 'w'){ |f| f.puts words_by_metaphone.to_yaml }
    words_by_metaphone
  end

  #Within a given collection of strings, find all those that have the minimum
  #Levenshtein distance to a given string (http://en.wikipedia.org/wiki/Levenshtein_distance).
  #Accepts a block to transform the collection of strings before calculating the
  #distance.
  def find_closest( given_string, collection)
    strings_by_distance = collection.inject( Hash.new{ |h,k| h[k]=[]}) do |h, string|
      if block_given? 
        h[Text::Levenshtein.distance( yield( string), given_string)] << string
      else
        h[Text::Levenshtein.distance( string, given_string)] << string
      end
      h
    end

    min_distance = strings_by_distance.min{ |a, b| a[0] <=> b[0]}[0]

    strings_by_distance[min_distance]
  end


  def read_tshirt( tshirt_phrase)
    if tshirt_phrase.respond_to?( :join)
      tshirt_phrase = tshirt_phrase.join( ' ')
    end

    phrase_metaphoned = tshirt_phrase.to_metaphone

    #Find words whose metaphone best matches the t-shirt's metaphone:
    close_words = if DICT_METAPHONE.has_key?( phrase_metaphoned)
      DICT_METAPHONE[phrase_metaphoned]
    else
      close_metaphones = find_closest( phrase_metaphoned, DICT_METAPHONE.keys)
      close_metaphones.map{ |m| DICT_METAPHONE[m]}.flatten
    end

    #Of these close words, find the one that is closest to the t-shirt's phrase,
    #or more than one if there is a tie for closeness:
    closest_words = if 1 == close_words.size
      close_words
    else
      find_closest( tshirt_phrase.to_normalized, close_words){ |w| w.to_normalized}
    end
  end

  module_function :find_closest, :read_tshirt

end #module TShirtReader

if __FILE__ == $0
  def read_tshirt( format, *arg)
    start = Time.now
    res = TShirtReader.read_tshirt( *arg)
    duration = Time.now - start
    
    arg = arg.join( ' ') if arg.respond_to?( :join)

    case format
      when :short
        puts res.join( ', ')
      when :medium
        puts "#{arg} => #{res.join( ', ')}"
      when :long
        puts '-' * 40
        puts "#{arg} => #{res.join( ', ')}"
        puts
        puts "It took #{duration}s to find this answer."
        res.each do |r|
          print "#{r} | "
          print "metaphone distance(#{arg.to_metaphone}, #{r.to_metaphone}) = "
          print "#{Text::Levenshtein.distance( arg.to_metaphone, r.to_metaphone)} | "
          print "phrase distance(#{arg.to_normalized}, #{r.to_normalized}) = "
          print "#{Text::Levenshtein.distance( arg.to_normalized, r.to_normalized)}"
          puts
        end
    end
  end

  unless ARGV.empty?
    read_tshirt( $DEBUG ? :long : :short, ARGV)
  else
    [
      "e scent shells",
      "q all if i",
      "fan task tick",
      "b you tea full",
      "fun duh mint all",
      "s cape",
      "pan z",
      "n gauge",
      "cap tin",
      "g rate full",
      "re late shun ship",
      "con grad yeul 8",
      "2 burr q low sis",
      "my crows cope",
      "add minus ray shun",
      "accent you ate it",
      "add van sing",
      "car knee for us",
      "soup or seed",
      "poor 2 bell o",
      "d pen dance",
      "s o tear rick",
      "4 2 it us",
      "4 2 n 8",
      "4 in R",
      "naan disk clothes your",
      "Granmda Atika Lee",
      "a brie vie a shun",
      "pheemeeneeneetee",
      "me c c p",
      "art fork",
      "liberty giblet",
      "zoo key knee",
      "you'll tight",
      "Luke I like",
      "mah deux mah zeal",
      "may gel omen yak",
      "half tell mall eau gist",
      "whore tea cull your wrist",
      "pant oh my m",
      "tear a ball",
      "a bowl i shun",
      "pre chair",
      "10 s",
      "e z",
      "1 door full",
      "a door",
      "hole e",
      "grand your",
      "4 2 5",
      "age, it ate her",
      "tear it or eel",
      "s 1"
    ].each{ |w| read_tshirt( $DEBUG ? :long : :medium, w)}
  end

end