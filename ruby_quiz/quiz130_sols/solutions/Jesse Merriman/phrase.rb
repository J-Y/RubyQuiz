module Hangman
  module Phrase
    BlankChar = '-'

    # Return a regular expression to match the given phrase (case insensitive).
    def Phrase.regexp phrase
      blank_esc = Regexp.escape BlankChar
      /^#{Regexp.escape(phrase).gsub(blank_esc, '.')}$/i
    end

    # Return an array of all the indices in phrase that have a blank character.
    def Phrase.blank_indices phrase
      is = []
      phrase.split(//).each_with_index do |letter, i|
        is << i if letter == BlankChar
      end
      is
    end
  end
end
