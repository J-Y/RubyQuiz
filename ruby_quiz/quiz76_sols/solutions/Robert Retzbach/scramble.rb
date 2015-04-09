#!C:\ruby\bin\ruby.exe

class String
  def munge
    if self.length > 3
      # start-, middle- and end-letters
      s, m, e = self[0, 1], self[1..-2], self[-1, 1]

      # munge them randomly
      s << m.split(//).sort_by{rand}.join << e
    else
      self
    end
  end

  def demunge demunger
    if self.length > 3
      # how possible words?
      words = demunger.lookup[ self.downcase.sort2 ]

      # word unknown
      return self if words.nil?

      if words.size == 1
        words.first
      else
        # delete words with different outer letters
        words.delete_if {|word| word !~ /^#{self[0,1].downcase}.*#{self[-1,1].downcase}$/}

        # pick random word if there are still more than one word
        words[ rand(words.size) ]
      end
    else
      self
    end
  end

  def sort2
    # rearrange string, e.g. "gathering" => "aegghinrt"
    self.split(//).sort.join
  end
end

class Demunger
  attr_accessor :lookup

  def initialize dictfilepath
    unless File.exists?("#{dictfilepath}.marshal")
      hashdump dictfilepath
    else
      hashload "#{dictfilepath}.marshal"
    end
  end

  # create a hash for looking up sorted words
  # and save it for further usage on hdd
  def hashdump dictfilepath
    @lookup = {}
    IO.foreach(dictfilepath) do |word|
      next unless word.size > 3
      word.chomp!
      @lookup[ word.sort2 ] ||= []
      @lookup[ word.sort2 ]  << word
    end
  end

  def hashload dictdumpfilepath
    @lookup = Marshal.load File.open(dictdumpfilepath, 'r')
  end
end

class TextMunge
  def initialize demunger = nil
    @demunger = demunger

    # greetings to JEG2 :)
    @letterclass = "A-Za-z\201\202\203\204\205\206\207\210\211\212"   <<
                   "\213\214\215\216\217\220\221\222\223\224\225\226" <<
                   "\227\230\231\232\233\235\240\241\242\243\244\245" <<
                   "\265\266\267\322\323\324\326\327\330\336\340\341" <<
                   "\342\343\344\345\351\352\353\354\355"
  end

  def munge text
    munged = ''
    # "isn't" is treated as "isn ' t"
    text.split(/([^#{@letterclass}])/).each do |word|
      puts word
      munged << word.munge
    end
    munged
  end

  def demunge text
    demunged = ''
    # depending on my dictionary, which uses '/', '-' and '\''
    # I take "tehre's" as whole word
    text.split(/([^#{@letterclass}\/'-])/).each do |word|
      demunged << word.demunge(@demunger)
    end
    demunged
  end
end

if __FILE__ == $0
  # usage examples
  # 
  #  MUNGING
  #   echo this is a test | text-munger.rb -m
  #   cat normal_text | text-munger.rb -m
  #   
  #  DEMUNGING
  #   echo tihs is a tset | text-munger.rb -d dic-0294.txt
  #   cat munged_text | text-munger.rb -d dic-0294.txt
  #
  case ARGV.shift
  when '-m'
    textmungecontrol = TextMunge.new
    puts textmungecontrol.munge(ARGF.read)
  when '-d'
    textmungecontrol = TextMunge.new(Demunger.new(ARGV.shift))
    puts textmungecontrol.demunge(ARGF.read)
  end
end
