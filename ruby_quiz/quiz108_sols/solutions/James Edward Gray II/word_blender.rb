#!/usr/bin/env ruby -w

require "io/wait"

# game date cache
CACHE_FILE = ".game_words"

if File.exist? CACHE_FILE  # load from cache
  word_list = File.open(CACHE_FILE) { |file| Marshal.load(file) }
else                       # build word list
  # prepare data structure
  words_by_signature = Hash.new { |words, sig| words[sig] = Array.new }

  # read dictionary
  File.foreach(ARGV.shift || "/usr/share/dict/words") do |word|
    word.downcase!
    word.delete!("^a-z")
  
    next unless word.length.between? 3, 6
  
    (words_by_signature[word.split("").sort.join] << word).uniq!
  end

  # prepare recursive signature search
  def choices(sig, seen = Hash.new { |all, cur| all[cur] = true; false }, &blk)
    sig.length.times do |i|
      shorter = sig[0...i] + sig[(i+1)...sig.length]
      unless seen[shorter]
        blk[shorter]
        choices(shorter, seen, &blk) unless shorter.length == 3
      end
    end
  end

  # prepare game data structure
  word_list = Hash.new

  # build game choices
  words_by_signature.keys.grep(/\A.{6}\Z/) do |possible|
    word_list[possible] = words_by_signature[possible]
  
    choices(possible) do |shorter_signature|
      if words_by_signature.include? shorter_signature
        word_list[possible].push(*words_by_signature[shorter_signature])
      end
    end
  end

  # cache for faster loads
  File.open(CACHE_FILE, "w") { |file| Marshal.dump(word_list, file) }
end

### game interface (requires Unix) ###
TERMINAL_STATE = `stty -g`
system "stty raw -echo cbreak"
at_exit { system "stty #{TERMINAL_STATE}" }
clear = `clear`

# a raw mode savvy puts
def out(*args) print(*(args + ["\r\n"])) end

# for easy selection
words = word_list.keys

rounds = 0
loop do
  # select letters
  letters = current = words[rand(words.size)]
  while word_list.include? letters
    letters = letters.split("").sort_by { rand }.join
  end
  letters.gsub!(/.(?=.)/, '\0 ')
  
  # round data
  advance       = false
  matches       = Array.new
  current_match = String.new
  start         = Time.now
  message       = nil
  last_update   = start - 1
  
  # round event loop
  until Time.now >= start + 2 * 60
    # game display
    if last_update <= Time.now - 1
      print clear

      out "Your letters:  #{letters}"
      out "   Time left:  #{120 - (Time.now - start).round} seconds"
      out "  Your words:  #{matches.join(', ')}"
      out
      unless message.nil?
        out message
        out
      end
      print current_match
      $stdout.flush
      
      last_update = Time.now
    end
    
    # input handler
    if $stdin.ready?
      char = $stdin.getc
  		case char
			when ?a..?z, ?A..?Z  # read input
			  current_match << char.chr.downcase
			  message       =  nil
        last_update   =  start - 1
      when ?\b, 127        # backspace/delete
        current_match = current_match[0..-2]
			  message       =  nil
        last_update   =  start - 1
      when ?\r, ?\n        # test entered word
        if word_list[current].include? current_match
          matches << current_match
          matches = matches.sort_by { |word| [word.size, word] }
          if not advance and current_match.length == 6
            advance = true
            message = "You will advance to the next round!"
          else
  			    message = nil
          end
        else
          message = "Unknown word."
        end
        current_match = String.new
        last_update   = start - 1
  		end
    end
  end
  
  # round results
  print clear
  missed = word_list[current] - matches
  unless missed.empty?
    out "Other words using \"#{letters}:\""
    out missed.sort_by { |word| [word.size, word] }.join(", ")
    out
  end
  if advance
    rounds += 1
    
    out "You made #{matches.size} word#{'s' if matches.size != 1}, ",
        "including at least one six letter word.  Nice work."
    out "Press any key to begin the next round."
    
    $stdin.getc
  else
    out "You made #{matches.size} word#{'s' if matches.size != 1}, ",
        "but failed to find a six letter word."
    
    break  # end game
  end
end

# game results
out "You completed #{rounds} round#{'s' if rounds != 1}.  Thanks for playing."
