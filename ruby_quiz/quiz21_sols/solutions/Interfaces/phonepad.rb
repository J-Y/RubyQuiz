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
  def run
  end
  def to_s
    @text.dup.insert(@cursor,'_')
  end
end

if $0 == __FILE__
  p = CLIPhonePad.new

  p.register do |ev| 
    puts "#{ev} at #{ev.when}"
    p.set_text(p.text+ev.digit, p.cursor+1) 
  end

  Thread.list[0].join
end
