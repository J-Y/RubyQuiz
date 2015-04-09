#!/usr/bin/ruby
#
# Ducksay
#
# A response to Ruby Quiz of the Week #52 [ruby-talk:161834]
#
# It's a script that generates funny talking animals, like the one at
# http://www.cowsay.net/
#
# From the command line, use --help for usage info.
# Basically, you can give some parameters, and you have to give the duck's
# speech on STDIN.
#
# Create a new template by subclassing Duck.
#
# You can also use it from inside Ruby -- use the say method of Duck, etc.
#
# Author: Dave Burt <dave at burt.id.au>
#
# Created: 23 Oct 2005
#
# Last modified: 24 Oct 2005
#
# Fine print: Provided as is. Use at your own risk. Unauthorized copying is
#             not disallowed. Credit's appreciated if you use my code. I'd
#             appreciate seeing any modifications you make to it.

class String
  def width
    inject(0) {|w, line| [w, line.chomp.size].max }
  end
  def height
    to_a.size
  end
  def top
    to_a.first
  end
  def middle
    to_a.values_at(1..-1)
  end
  def bottom
    to_a.last
  end
end

class Duck
  def self.say(speech="quack?", *args)
    balloon(speech) + body(*args)
  end

  def self.balloon(speech)
    " _#{ '_' * speech.width }_\n" +
      if speech.chomp =~ /\n/
        "/ %-#{ speech.width }s \\\n" % speech.top.chomp +
        speech.middle.map do |line|
          "| %-#{ speech.width }s |\n" % line.chomp
        end.join +
        "\\ %-#{ speech.width }s /\n" % speech.bottom.chomp
      else
        "< #{ speech.chomp } >\n"
      end +
    " -#{ '-' * speech.width }-\n"
  end

  def self.body(thoughts='\\', eyes='cc', tongue='  ')
"       #{thoughts}
        #{thoughts}
        _   ___
       / \\ /   \\
       \\. |: #{eyes}|
        (.|:,---,
        (.|: \\( |
        (.    y-'
         \\ _ / #{tongue}
          m m
"
  end
end

class Cow < Duck
  def self.body(thoughts='\\', eyes='oo', tongue='  ')
"  #{thoughts}   ^__^
   #{thoughts}  (#{eyes})\\_______
      (__)\\       )\\/\\
       #{tongue} ||----w |
          ||     ||
"
  end
end

class DuckOnWater < Duck
  def self.body(thoughts='\\', eyes='º', tongue='>')
"    #{thoughts}
     ` #{tongue[0, 1]}(#{eyes[0, 1]})____,
        (` =~~/
~^~^~^~^~`---'^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
"
  end
end

if $0 == __FILE__
  if ARGV.include?("--help")
    puts "usage: #$0 animal thoughts eyes tongue <speech\n"
    puts "animals: Duck Cow DuckOnWater\n"
    puts "e.g.: #$0 DuckOnWater o x ) </etc/fortune\n"
  else
    animal = Object.const_get(ARGV.shift) rescue Duck
    puts animal.say(STDIN.read, *ARGV)
  end
end
