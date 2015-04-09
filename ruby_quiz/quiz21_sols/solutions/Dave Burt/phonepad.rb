#!/usr/bin/ruby
#
# Phone Typing
#
# A mobile phone keypad simulator or two and a new input mechanism or two
#
# A response to Ruby Quiz of the Week #20 - Phone Typing [ruby-talk:125427]
# Some of this code is taken from the quiz question, and is by Hans Fugal and
# James Edward Gray II: most of the classes TapEvent, PhonePad, CLIPhonePad,
# and CharPhonePad.
# The bits that are an answer to the quiz were written by me.
# IconicTapHandler and LetterWiseTapHandler are based on algorithms found
# around the place, and are credited in local comments.
#
# Author: Dave Burt <dave at burt.id.au>
#
# Created: 26 Feb 2005
#
# Last modified: 29 Feb 2005
#
# Fine print: Provided as is. Use at your own risk. Unauthorized copying is
#             not disallowed. Credit's appreciated if you use my code. I'd
#             appreciate seeing any modifications you make to it.
#

class TapEvent
  attr_reader :when, :digit
  def initialize(digit)
    @digit = digit
    @when = Time.now
  end
  def to_s
    @digit
  end
end

class PhonePad
  InputMap = {
    '0' => [' ', '0'],
    '1' => %w[1],
    '2' => %w[a b c 2],
    '3' => %w[d e f 3],
    '4' => %w[g h i 4],
    '5' => %w[j k l 5],
    '6' => %w[m n o 6],
    '7' => %w[p q r s 7],
    '8' => %w[t u v 8],
    '9' => %w[w x y z 9],
    '*' => %w[*],
    '#' => %w[#],
  }
  attr_reader :text, :cursor
  def set_text(text,cursor)
    @text = text
    @cursor = cursor
  end
  def register(&block)
    @observers.push block
  end
  def initialize
    @observers = []
    @text = ''
    @cursor = 0
  end
  def notify_observers(digit)
    if digit =~ /[0-9*#]/
      @observers.each { |block| block.call(TapEvent.new(digit)) }
    end
  end
end

class CLIPhonePad < PhonePad
  def initialize
    super
    Thread.new do
      while not $stdin.eof? do
$stdin.readline.split('').each { |c| notify_observers(c) }
      end
    end
  end
  def set_text(text,cursor)
    super(text,cursor)
    puts to_s
  end
  def to_s
    @text.dup.insert(@cursor,'_')
  end
end

class TkPhonePad < PhonePad
  def initialize
    super
    Thread.new do
      require "tk"
      root = TkRoot.new() { title "TK Phone Pad" }
      @t = TkText.new(root,
        :width => 40, :height => 8
      ).grid('row'=>0, 'column'=>0, 'columnspan'=>3)
      [["1", "2\nabc", "3\ndef"], 
      ["4\nghi", "5\njkl", "6\nmno"], 
      ["7\npqrs", "8\ntuv", "9\nwxyz"],
      ["#", "0\n_", "*"]
      ].each_with_index do |a, row|
     	  a.each_with_index do |s, col|
     		  TkButton.new(root, :text => s,
            :command => proc { notify_observers(s[0].chr) },
            :width => 10, :height => 3
          ).grid(:row => row + 2, :col => col)
    	  end
      end
      Tk.mainloop
    end
  end
  def set_text(text,cursor)
    super(text,cursor)
    @t.value = @text.dup
  end
end

class CharPhonePad < PhonePad
  def initialize
    super
    Thread.new do
      loop do
        case c = self.class.read_char
        when 3, 4, 26, 27  # Break on Ctrl+C, Ctrl+D, Ctrl+Z, Escape
          break
        when 43  # convert '+' to '*' for ease of typing on numpad
          c = 42
        when 45, 46, 47  # convert '-', '.', '/' to '#' for ease of typing
          c = 35
        end
        notify_observers(c.chr)
      end
    end
  end
  def set_text(text, cursor)
    super(text, cursor)
    puts to_s
  end
  def to_s
    @text.dup.insert(@cursor, '_')
  end

  begin
    require "Win32API"
    def self.read_char
      c = Win32API.new("crtdll", "_getch", [], "L").Call
    end
  rescue LoadError
    def self.read_char
      system "stty raw -echo"
      STDIN.getc
    ensure
      system "stty -raw echo"
    end
  end
end

class TapHandler
  def initialize(phone_pad)
    @p = phone_pad
  end
end

class NoOpTapHandler < TapHandler
  def process_event(ev)
    puts "#{ev} at #{ev.when}"
    @p.set_text(@p.text+ev.digit, @p.cursor+1)
  end
end

class MultipressTapHandler < TapHandler
  attr_accessor :timeout
  def initialize(phone_pad, timeout = 1.5)
    super(phone_pad)
    @timeout = timeout
  end
  def process_event(ev)
    if (@last_event && 
        ev.digit == @last_event.digit &&
        Time.now - @last_event.when < timeout)
      char_set = PhonePad::InputMap[ev.digit]
      char_index = (char_set.index(@p.text[-1].chr) + 1) % char_set.size
      @p.set_text(@p.text[0..-2] + char_set[char_index], @p.cursor)
    else
	### modified by JEG2 for discussion example ###
      @p.set_text(@p.text+PhonePad::InputMap[ev.digit][0], @p.cursor+1)
    ### actual code by Dave Burt ###
#      @p.set_text(@p.text+ev.digit, @p.cursor+1)
    end
    @last_event = ev
  end
end

class IconicTapHandler < TapHandler
  # method taken from:
  # Iconic Text Entry Using a Numeric Keypad
  # 2002
  # John Jannotti
  # Massachusetts Institute of Technology 
  # http://www.pdos.lcs.mit.edu/~jj/jannotti.com/papers/iconic-uist02/
  #
  # This horrible method gets a slower predicted input rate than Multipress!

  InputMapReverse = {
    'a' => %w[426 2426],
    'b' => %w[8 14758],
    'c' => %w[2145],
    'd' => %w[25847],
    'e' => %w[3], #147852  was also specified
    'f' => %w[14712],
    'g' => %w[6 214785],
    'h' => %w[1425],
    'i' => %w[2580],
    'j' => %w[2587],
    'k' => %w[248],
    'l' => %w[1478 2589],
    'm' => %w[41536],
    'n' => %w[4152],
    'o' => %w[0 2684],
    'p' => %w[14725],
    'q' => %w[14528],
    'r' => %w[475],
    's' => %w[5 2154],
    't' => %w[7 12358],
    'u' => %w[2541 2563],
    'v' => %w[153],
    'w' => %w[14263],
    'x' => %w[1524 159],
    'y' => %w[158 1357],
    'z' => %w[1245],
    ' ' => %w[9],
  }
  InputMapTree = {}
  InputMapReverse.each_pair do |letter, codes|
    codes.each do |code|
      node = InputMapTree
      prev_node = node
      code.each_byte do |byte|
        # the next line will barf if any code is a prefix to another code
        # (i.e. if node is a String instead of a Hash)
        node[byte.chr] = {} unless node[byte.chr]
        prev_node = node
        node = node[byte.chr]
      end
      prev_node[code[-1].chr] = letter
    end
  end
  
  def initialize(phone_pad)
    super(phone_pad)
    @node = InputMapTree
  end
  def process_event(ev)
    case @node[ev.digit]
    when String
      @p.set_text(@p.text+@node[ev.digit], @p.cursor+1)
      @node = InputMapTree
    when Hash
      @node = @node[ev.digit]
    else  # nil: bad input combo
      @node = InputMapTree
    end
  end
end

class LetterWiseTapHandler < TapHandler
  # method taken from:
  # MacKenzie, I. S., Kober, H., Smith, D., Jones, T., Skepner, E. (2001).
  # LetterWise: Prefix-based disambiguation for mobile text input.
  # Proceedings of the ACM Symposium on User Interface Software and Technology
  #  - UIST 2001, pp. 111-120. New York: ACM.
  # http://www.yorku.ca/mack/uist01.html
  
  # A lot of the logic in this method is captured in the InputMap, which maps
  # prefixes of up to 3 letters and a key (0-9) onto an array of letters in
  # most-likely-first order.
  
  #require 'yaml'
  #InputMap = YAML.load_file('predict3.yaml')  # 1.8MB, ~ 6 seconds to load
  InputMap = eval(File.read('predict3.rb'))  # 2.3MB, ~ 3 seconds to load
  
  def initialize(phone_pad)
    super(phone_pad)
    @cycle = ['*']
  end
  def process_event(ev)
    prefix = @p.text[/\w{0,3}$/]
    if ev.digit == '*'  # change last letter
      @cycle.push @cycle.shift  # rotate
      @p.set_text(@p.text[0..-2], @p.cursor - 1)
    elsif InputMap[prefix]
      @cycle = InputMap[prefix][ev.digit].dup
    else
      @cycle = InputMap[nil][ev.digit].dup
    end
    @cycle ||= %w[. ! - & @ $ * +]
    @p.set_text(@p.text + @cycle[0], @p.cursor + 1)
  end
end

### options parsing added by JEG2 ###
if $0 == __FILE__
	require "optparse"
	
	# defaults
	pad = :raw
	tap = :letterwise
	
	# parse options
	opts = OptionParser.new do |opts|
		opts.banner = "Usage:  #$0 [OPTIONS]"
		
		opts.separator ""
		opts.separator "Specific Options:"
		
		opts.on( "-i INTERFACE",
		         [:raw, :tk, :cli],
		         "Interface you would like to use:",
		         "  raw, tk or cli." ) do |v|
			pad = v
		end
		opts.on( "-m MODE",
		         [:letterwise, :multipress, :iconic, :noop],
		         "The input algorithm to use:",
		         "  letterwise, multipress, iconic or noop." ) do |v|
			tap = v
		end
		opts.on( "-h", "-?", "--help",
		         "Show this text." ) do
			puts opts
			exit
		end
	end
	opts.parse!(ARGV)
  
	# handle results
	case pad
	when :raw then p = CharPhonePad.new
	when :tk  then p = TkPhonePad.new
	when :cli then p = CLIPhonePad.new
	end
	case tap
	when :letterwise then tap_handler = LetterWiseTapHandler.new(p)
	when :multipress then tap_handler = MultipressTapHandler.new(p)
	when :iconic     then tap_handler = IconicTapHandler.new(p)
	when :noop       then tap_handler = NoOpTapHandler.new(p)
	end

	# run program
	p.register { |ev| tap_handler.process_event(ev) }
	Thread.list[0].join
end

### Dave's original code ###
#if $0 == __FILE__
#  
#  #p = CLIPhonePad.new  # Command-line interface
#  p = CharPhonePad.new  # Raw command-line interface
#  #p = TkPhonePad.new  # TK interface
#  
#  #tap_handler = NoOpTapHandler.new(p)  # just dump digits pressed
#  #tap_handler = IconicTapHandler.new(p)  # tap the shape of a letter on the keypad!
#  #tap_handler = MultipressTapHandler.new(p)  # standard multi-press, 1.5s timeout
#  tap_handler = LetterWiseTapHandler.new(p)  # letter-wise prediction; * to change letter
#
#  p.register do |ev|
#    tap_handler.process_event(ev)
#  end
#
#  Thread.list[0].join
#end
