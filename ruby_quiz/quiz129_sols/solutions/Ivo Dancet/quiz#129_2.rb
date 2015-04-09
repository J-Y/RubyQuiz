require 'curses'
require 'logger'
require 'yaml'

class NamePicker
  attr_reader :name, :org
  
  def initialize
    @names = YAML.load(File.read("names.yml"))
    
    raise "Not enough names in list" if @names.select{ |key,value| value["picked"].nil?  }.length == 0
    
    begin
      @random_key = rand(@names.length)
      picked_record = @names[@names.keys[@random_key]]
    end while picked_record["picked"] == true
      
    @name = picked_record["name"].to_s
    @org = picked_record["organisation"].to_s
    
    save_names
  end
  
  def save_names
    file = File.open("names.yml", "w")
    @names[@names.keys[@random_key]]["picked"] = true
    file.write @names.to_yaml
    file.close
  end
  
end

class Letters
  
  @@letters = nil
  
  def initialize(letter, size)
    if @@letters.nil?
      readLetters
    end
    getLetter(letter, size)
  end
  
  def readLetters
    file = File.open("ascii_letters5_5.txt","r").readlines
    @@letters = {}
    (("A".."Z").to_a + [" ",".",","] + ("0".."9").to_a ).each do |key|
      @@letters[key]= file[0..4].collect { |a| a.chomp }
      file = file[6..-1]
    end
  end
  
  def getLetter( letter, size )
    letter_lines = @@letters[letter]
    @letter = []
    letter_lines.each do |line|
      size.times do |i|
        @letter << line.split("").collect { |l| l * size }.join("")
      end 
    end
  end
  
  def lines
    @letter
  end
  
  def width
    @letter.first.length
  end
  
  def height
    @letter.length
  end
end

class Show
  include Curses
  
  def initialize( picked )
    init_screen
    @win = Window.new( lines, cols, 0, 0 )
    
    @picked = picked
    
    shrink_letters

    show_winner

    show_org

    sleep 5

    move_winner

    sleep 3
    
    close
  end
  
  def shrink_letters
    @picked.name.upcase.split("").each do |letter|
      self.shrink letter
    end
  end
  
  def shrink( letter )
    @letters = [] if @letters.nil?
      
    20.downto(1) do |size|
      @letter = Letters.new( letter, size )
      centerLetterOnScreen
      addLetters
      @win.refresh
      sleep 0.02
    end
    
    @letters << letter
  end
  
  def addLetters(x=0, y=0)
    x = 20 + x
    y = 20 + y
    
    @letters.each do |letter|
      @win.setpos(y,x)
      big_letter = Letters.new(letter, 1).lines
      5.times do |i|
        @win.addstr big_letter[i]
        @win.setpos(y+i+1,x)
      end
      x += 6
    end
  end
  
  def show_org(x=0, y=0)
    x = 20 + x
    y = 30 + y
    
    @picked.org.upcase.split("").each do |letter|
      @win.setpos(y,x)
      big_letter = Letters.new(letter, 1).lines
      5.times do |i|
        @win.addstr big_letter[i]
        @win.setpos(y+i+1,x)
      end
      x += 6
    end
    @win.refresh
  end
  
  def centerLetterOnScreen
    @win.clear
    
    letter_start = (@letter.width - cols)/2
    letter_line_start = (@letter.height - lines)/2
    
    if letter_line_start > 0
      letter_line_start.upto(letter_line_start+lines) do |i|
        if letter_start > 0
          @win.addstr @letter.lines[i][letter_start..-1]
          @win.addstr "\n"
        else
          letter_start.upto(0){ @win.addstr " " }
          @win.addstr @letter.lines[i] + "\n"
        end
      end
    else
      letter_line_start.upto(0) do
        @win.addstr "\n"
      end
      0.upto(@letter.height-1) do |i|
        letter_start.upto(0){ @win.addstr " " }
        @win.addstr @letter.lines[i] + "\n"
      end
    end
    
  end
  
  def show_winner
    @win.clear
    addLetters
    @win.refresh
  end
  
  def move_winner
    (lines - 20).times do |i|
      @win.clear
      addLetters(i,i)
      @win.refresh
      sleep 0.02
    end
  end
  
  def close
    close_screen
  end

end

$logger = Logger.new("log.log")

picked = NamePicker.new

show = Show.new picked