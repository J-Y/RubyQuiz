# My first Ruby quiz. Been toying with Ruby for 6 months
# or so now. I'm looking forward to seeing how others
# who are more experieced handle this problem. No extra
# credit for me this week as I didn't do any dictionary
# lookups.  -Colin

# Just for formatting the output later
LINE = "----------------------------------------------------"

# The codes, as pasted from the RubyQuiz site
codes = {'A'=>'.-','B'=>'-...','C'=>'-.-.','D'=>'-..',
         'E'=>'.','F'=>'..-.','G'=>'--.','H'=>'....',
         'I'=>'..','J'=>'.---','K'=>'-.-','L'=>'.-..',
         'M'=>'--','N'=>'-.','O'=>'---','P'=>'.--.',
         'Q'=>'--.-','R'=>'.-.','S'=>'...','T'=>'-',
         'U'=>'..-','V'=>'...-','W'=>'.--','X'=>'-..-',
         'Y'=>'-.--','Z'=>'--..'}
# I found it easier to put them in opposite of how I was
# really going to use them so here I flip-flop the hash
@index = codes.invert

# Grab the morse code from the command line
code_string = ARGV[0]

# Sets up an array to plunk our answers into
@answers = []

# A method that takes a two-item array of values:
#   First - the letters of the answer so far
#   Last - the remaining dots and dashes to translate
def translate(answer)
  # Cycle through the various possible lengths of the
  # letters. Since they can only be 4 chrs long, we
  # stop at 4.
  (1..4).each do |n|
    # for each letter / morse code pair
    @index.each_pair do |k,v|
      # If first (1, 2, 3, or 4) letters in the part
      # remaining to be translated are the same as a
      # morse code letter...
      if answer[1][0,n] == k
        new_answer = [
          # Build an array that has the original part
          # already translated...
          answer[0] + v,
          # And the remaining part to translate with
          # the part we just translated lobbed off.
          answer[1].sub(k, '')
        ]
        if new_answer[1] == ""
          # If we've translated the whole word, then
          # add it into our final aray of possibilities.
          @answers << new_answer[0]
        else
          # Otherwise, pass what we've got back to this
          # same method and keep translating.
          translate new_answer
        end
      end
    end
  end
end

translate(["",code_string])

puts LINE
puts "The morse code you entered was: " + code_string
puts LINE
puts "The possible translations are:"
puts LINE
# I dunno how but I ended up with some non-unique answers.
# No matter, the uniq method makes quick work of that.
puts unique = @answers.uniq.sort
puts LINE
puts "Total possible answers: " + unique.length.to_s
