# texttwist.rb
#
#  Created by Dale Martenson on 2007-01-07.
#  Copyright 2007 Dale Martenson. All rights reserved.

require 'tk'

class TextTwist
  # Algorithm derived from online book by Robert Sedgewick and Kevin Wayne.
  # It was origomally written in Java. 
  #
  # References:
  # http://www.cs.princeton.edu/introcs/31datatype/
  # http://www.cs.princeton.edu/introcs/31datatype/TextTwist.java.html

  class Profile < Hash
    def initialize( word )
      super
      word.downcase.each_byte do |b|
        self[b.chr] = 0 unless self.has_key?(b.chr)
        self[b.chr] += 1
      end
    end

    def contains( p )
      p.each_pair do |k,v|
        return false unless self.has_key?(k)
        return false if self[k] < v
      end
      true
    end
  end

  attr_reader :word, :words

  def initialize( dictionary, word=nil )
    @dictionary = dictionary
    @dictionary.collect! {|x| x.downcase}
    @dictionary.sort!
    word.nil? ? restart : start( word )
  end

  def start( word )
    @word = word.downcase
    @profile = Profile.new( @word )
    @words = process
  end

  def process
    result = []

    @dictionary.each do |dw|
      next if dw.length < 3 || dw.length > @word.length 
      result << dw if @profile.contains( Profile.new( dw ) )
    end

    result
  end

  def mix
    a = @word.split(//)
    1.upto(a.length) do
      i1 = rand(a.length) 
      i2 = rand(a.length)
      t = a[i1]
      a[i1] = a[i2]
      a[i2] = t
    end
    a  
  end

  def check( word )
    @words.include?( word.downcase )
  end
  
  def contains( word )
    @profile.contains( Profile.new( word ) )
  end

  def restart
    six_letter_words = []
    @dictionary.each do |w|
      six_letter_words << w if w.length == 6
    end

    start( six_letter_words[ rand(six_letter_words.size) ] )
  end
end

class TextTwistUI
  # Tk UI Class
  #
  # Why Tk? Simple ... available by default in most Ruby installations.
  
  BACKGROUND_COLOR = "#666699"
  BOARD_BACKGROUND_COLOR = "#707099"
  ROUND_TIME = 90
  ROUND_SCORE = 100
  
  def score_word( word )
    word.size * 2**(word.size-2)
  end
  
  def show_letters
    @letters.configure( 'text'=>@tt.mix.join(" ") )
  end
  
  def start_clock
    @clock = ROUND_TIME
    @timer = TkAfter.new( 1000, -1, proc { update_clock } )
    @timer.start
  end
  
  def stop_clock
    stop = TkPhotoImage.new { file "Stop.gif" }
    @image_field.configure( 'image'=> stop ) 
    @timer.stop
  end
  
  def check_score
    if @round_score > ROUND_SCORE 
      @next_round = true
      @round += 1
      @message.configure( 'text'=>"Get ready for round #{@round}. Press START to continue.")
    else
      @next_round = false
      @message.configure( 'text'=>"Good try -- GAME OVER!")
    end
  end
  
  def display_missed_words
    (@master_word_list - @word_list).each do |word|
      # There is probably a better way to highlight missed words. 
      @word_list_area[word.size].insert( 'end', "-> #{word} <-" )
    end
  end
  
  def update_clock
    if @clock > 0
      @clock -= 1 
      @clock_field.configure( 'text'=>"Time: #{@clock}" )
    else
      stop_clock
      check_score
      display_missed_words
    end
  end
  
  def update_score
    @score_field.configure( 'text'=> "Round Score: #{@round_score} Total Score: #{@total_score}")
  end

  def update_round
    @round_field.configure( 'text'=> "Round: #{@round}")
  end
  
  def restart
    # FIXME: It is possible, but not likely, that the base word that is picked will not produce possible words
    # to advance the round (< ROUND_SCORE). Some type of check could be added.
    begin
      @tt.restart
      # DEBUG: Uncomment these lines to see which word was picked and the base word and the list of 
      # words that can be made. 
      # p @tt.word
      # p @tt.words
      @master_word_list = @tt.process
    
      @possible_score = 0
      @master_word_list.each { |word| @possible_score += score_word(word) }
      @message.configure( 'text'=>"Possible score: #{@possible_score}" )    
    end while @possible_score < ROUND_SCORE
      
    # clear word lists 
    @word_list_area[3].delete(0, 'end')
    @word_list_area[4].delete(0, 'end')
    @word_list_area[5].delete(0, 'end')
    @word_list_area[6].delete(0, 'end')
    
    show_letters 
    start_clock
    update_clock
    if !@next_round
      @total_score = 0
      @round = 1
    end
    @round_score = 0
    update_score
    update_round
    go = TkPhotoImage.new { file "Go.gif" }
    @image_field.configure( 'image'=> go ) 
  end
  
  def initialize( tt )
    @tt = tt
    @word_list = []
    @word = ''
    @clock = ROUND_TIME
    @total_score = 0
    @round_score = 0
    @round = 1
    @index = 0
    @next_round = false

    root = TkRoot.new { 
      title "TextTwist (Ruby+Tk)"
      background BACKGROUND_COLOR 
    }
    top = TkFrame.new(root) { 
      background BACKGROUND_COLOR 
    }
    
    # FIXME: The word lists should be scrolling.
    words_area = TkFrame.new(top) { 
      background BACKGROUND_COLOR 
    }
    @word_list_area = {}
    [3,4,5,6].each do |ws|
      @word_list_area[ws] = TkListbox.new(words_area) { 
        background BOARD_BACKGROUND_COLOR 
      }
      @word_list_area[ws].pack('fill'=>'both', 'side'=>'left')
    end
    words_area.pack('fill'=>'both', 'side'=>'top')
    
    game_area = TkFrame.new(top) { 
      background BACKGROUND_COLOR 
    }
    display_area = TkFrame.new(game_area) { 
      background BACKGROUND_COLOR 
    }
    logo = TkPhotoImage.new { 
      file "logo.gif" 
    }
    @image_field = TkLabel.new(display_area) { 
      image logo; relief 'flat'
      borderwidth '0'
      pack 
    }
    display_area.pack('fill'=>'both', 'side' =>'left')
    
    play_area = TkFrame.new(game_area) { 
      background BACKGROUND_COLOR 
    }
    @round_field = TkLabel.new(play_area) { 
      text 'Round: --'
      background BACKGROUND_COLOR
      pack 'padx'=>10, 'pady'=>10
    }
    @score_field = TkLabel.new(play_area) { 
      text 'Round Score: ----- Total Score: -----'
      background BACKGROUND_COLOR
      pack 'padx'=>10, 'pady'=>10
    }
    @clock_field = TkLabel.new(play_area) { 
      text 'Time: --'
      background BACKGROUND_COLOR
      pack 'padx'=>10, 'pady'=>10
    }
    message_area = TkFrame.new(play_area) { 
      background BACKGROUND_COLOR 
    }
    @message = TkLabel.new(message_area) { 
      text ''
      background '#d9d900'
      borderwidth '2'
      width '40'
      relief 'raised'
      pack 'padx'=>10, 'pady'=>10
    }
    message_area.pack('fill'=>'both', 'side' =>'top')
    
    board_area = TkFrame.new(play_area) { 
      background BACKGROUND_COLOR 
    }
    @label = []
    0.upto(5) do |i|
      @label[i] = TkLabel.new(board_area) { 
        text '-'
        font 'Arial 24 normal'
        background BOARD_BACKGROUND_COLOR
        relief 'groove'
        width '3' 
      }
      @label[i].pack( 'side'=>'left', 'padx'=>10, 'pady'=>10 )
    end
    board_area.pack('fill'=>'both', 'side' =>'top')

    letter_area = TkFrame.new(play_area) { 
      background BACKGROUND_COLOR 
    }
    @letters = TkLabel.new(letter_area) { 
      text ''
      font 'Arial 24 normal'
      background BACKGROUND_COLOR
      width '10' 
    }
    @letters.pack( 'side'=>'top', 'padx'=>10, 'pady'=>10 )
    letter_area.pack('fill'=>'both', 'side' =>'top')
    
    control_area = TkFrame.new(play_area) { 
      background BACKGROUND_COLOR 
    }
    # FIXME: How do I change the color of buttons? 'background' and 'foreground' don't seem to have an effect. 
    # At least not when run on Mac OS X.
    TkButton.new(control_area) { 
      text 'Exit'
      command { proc exit }
    }.pack('side'=>'right', 'padx'=>10, 'pady'=>10)
    mix_p = proc { show_letters }
    TkButton.new(control_area) { 
      text 'Mix'
      command mix_p
    }.pack('side'=>'right', 'padx'=>10, 'pady'=>10)
    start_p = proc { restart }
    TkButton.new(control_area) { 
      text 'Start'
      command start_p
    }.pack('side'=>'right', 'padx'=>10, 'pady'=>10)
    control_area.pack('fill'=>'both', 'side' =>'top')

    play_area.pack('fill'=>'both','side'=>'top')  
    game_area.pack('fill'=>'both', 'side'=>'top')
    top.pack('fill'=>'both', 'side' =>'top')
    
    # Bind to receive all keyboard events. We really only care about RETURN, BACKSPACE 
    # and letters valid in our set for the round being played.    
    root.bind('Any-Key', 
      proc{ |e|
        return if @clock == 0        
        if e.keysym.size == 1 && @index < 6
          if @tt.contains(@word+e.keysym)
            @word << e.keysym
            @label[@index].configure('text'=>"#{e.keysym}")
            @index += 1
          else
            @message.configure( 'text'=>'Invalid letter!' )
          end
        elsif /BackSpace/.match(e.keysym)
          if @word.length > 0
            @word.chop!
            @index -= 1
            @label[@index].configure('text'=>'-')
          end
        elsif /Return/.match(e.keysym)
          if @word.size < 3
            @message.configure( 'text'=>'Word too short! Must be between 3 & 6 letters.' )
          elsif @tt.check(@word) 
            if @word_list.include?( @word )
              @message.configure( 'text'=>'You already have that word!' )
            else
              @word_list << @word
  
              @word_list_area[@word.size].insert( 'end', @word )
              
              word_score = score_word( @word )
              @round_score += word_score
              @total_score += word_score
              update_score
                
              @message.configure( 'text'=>"Good word: #{@word}" )
            end
          else
            @message.configure( 'text'=> 'That is not a known word!' )
          end
          @label[0].configure( 'text'=>'-' )
          @label[1].configure( 'text'=>'-' )
          @label[2].configure( 'text'=>'-' )
          @label[3].configure( 'text'=>'-' )
          @label[4].configure( 'text'=>'-' )
          @label[5].configure( 'text'=>'-' )
          @word = ''
          @index = 0
        else
          # DEBUG: Adding this helps to determine the symbol name for the key that was pressed.
          #  @message.configure( 'text'=>"e.keysym: #{e.keysym}")
        end
      }
    )
  end
end

# MAIN PROGRAM -- where the magic begins

# Using the crossword dictionary from "Moby Word Lists" by Grady Ward (part of 
# Project Gutenberg). I reduced the dictionary to only words that are 3 to 6 
# characters in length. 
#
# Note: This may not be the best dictionary for this game, but it works. It 
# does contain numerous obscure words which is both good and bad.
#
#     irb(main):001:0> f = File.open("crosswd.txt")
#     => #<File:crosswd.txt>
#     irb(main):002:0> of = File.open("3-6.txt","w+")
#     => #<File:3-6.txt>
#     irb(main):003:0> f.each_line do |line|
#     irb(main):004:1*   l = line.strip
#     irb(main):005:1>   if l.length >= 3 && l.length <= 6 then
#     irb(main):006:2*    of.puts( l )
#     irb(main):007:2>   end
#     irb(main):008:1> end
#     => #<File:crosswd.txt>
#     irb(main):009:0> of.close
#     => nil
#
# References:
# http://www.gutenberg.org/etext/3201

dictionary = []
f = File.open("3-6.txt")
dictionary = f.read.split

tt = TextTwist.new( dictionary )

TextTwistUI.new( tt )
Tk.mainloop