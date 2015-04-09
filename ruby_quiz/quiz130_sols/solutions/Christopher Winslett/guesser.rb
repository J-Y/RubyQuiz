class Guesser
  attr_accessor :length, :known, :list, :unknown, :not_words 

  def initialize(args)
    @length = args[:known].length 
    @known = args[:known].split(//)
    @unknown = args[:unknown] 
    @not_words = []
    @file = args[:file] || "words.txt"    
  end


  def guess
    @list.nil? ? load_database : filter

    if @list.length > 1
      letter_array = construct_letter_array 

      @list.each { | word | word.split(//).each_with_index { | letter, index | letter_array[index][letter.to_sym] += 1 if letter =~ /[A-Za-z]/ } }

      best_guess = Array.new

      letter_array.each_with_index do | letters, index |
        letter = letters.sort_by { | letter, value | value }.reverse.first
        best_guess << [letter[0], @known[index] == '-' ? letter[1] : 0]
      end

      letter_guess = best_guess.sort_by { | guess, number | number }.last
      [letter_guess[0], best_guess.rindex(letter_guess)]
    elsif @list.length == 1
      @list[0]
    else
      key = @known.index("-")
      letter = nil

      loop do
        letter = random_char
        break if @unknown[key].index(letter).nil?
      end

      [letter, key]
    end
  end

  def filter
    regex = create_regex
    @list = @list.delete_if { | item | !(item =~ regex) }
  end

  def construct_letter_array
    letter_array = Array.new
    0.upto(@length-1) do | i |
      letter_array[i] = Hash.new
      ("a".."z").to_a.each { | key | letter_array[i][key.to_sym] = 0 }
      ("A".."Z").to_a.each { | key | letter_array[i][key.to_sym] = 0 }
    end
    letter_array
  end

  def create_regex
    regex = ''
    unknown_length = 0
    @known.each_with_index do | letter, index |
      if letter == "-"
        if @unknown[index].length == 0
          unknown_length += 1
          regex << ".{#{unknown_length}}" if index + 1 == @known.length  && unknown_length > 0
	else
	  regex << ".{#{unknown_length}}" if unknown_length > 0
          regex << "[^#{@unknown[index].map { | letter | letter }}]"
	  unknown_length = 0
	end
      else
        regex << ".{#{unknown_length}}" if unknown_length > 0
        regex << "[#{letter}]"
	unknown_length = 0
      end
    end

    if @not_words &&  @not_words.length > 0
      [Regexp.new("^#{regex}$")] << Regexp.new("^(#{@not_words.join('|')})$")
    else
      Regexp.new("^#{regex}$")
    end
  end

  private
  def random_char( len=1 )
      chars = ("a".."z").to_a
      char = ""
      1.upto(len) { |i| char << chars[rand(chars.size-1)]  }
      return char
  end

  def load_database
    @list = `egrep #{create_regex.source} #{@file}`.split(/\n/) 
  end
end
