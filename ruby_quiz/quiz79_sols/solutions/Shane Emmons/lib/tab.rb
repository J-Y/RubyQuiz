#!/usr/local/bin/ruby -w

class Tab

  attr_reader :file, :music

  def initialize( file )
    @file = file
  end

  def parse( file = @file )
    @music = Array.new
    tab = Hash.new { |hash, key| hash[key] = Array.new }

    File.open(file).read.each do |line|
      next unless line =~ /^[EADGBe]/
      bar = line.chomp.split(//)
      bar.each do |note|
        next if note =~ /[EADGBe|]/
        tab[bar[0]] << note
      end
    end

    ['E', 'A', 'D', 'G', 'B', 'e'].each do |string|
      tab[string].each_index do |i|
        @music[i] = '' unless @music[i]
        @music[i] += tab[string][i]
      end
    end

    @music
  end

end

if __FILE__ == $0
    tab = Tab.new('tabs/Em.tab')
    print "\"#{tab.parse.join('", "')}\"\n\n"
end
