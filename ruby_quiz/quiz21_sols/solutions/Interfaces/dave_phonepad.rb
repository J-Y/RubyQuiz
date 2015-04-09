require "phonepad"

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

class NoOpTapHandler
  def initialize(phone_pad)
    @p = phone_pad
  end
  def process_event(ev)
    puts "#{ev} at #{ev.when}"
    @p.set_text(@p.text+ev.digit, @p.cursor+1)
  end
end

if $0 == __FILE__
  p = CharPhonePad.new
  tap_handler = NoOpTapHandler.new(p)

  p.register do |ev|
    tap_handler.process_event(ev)
  end

  Thread.list[0].join
end
