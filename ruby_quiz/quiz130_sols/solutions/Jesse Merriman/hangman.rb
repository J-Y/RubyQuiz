#!/usr/bin/env ruby

require 'game'
require 'getoptlong'

class String
  # Taken & mildly modified from ActiveSupport.
  def camelize(first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    else
      self[0].chr + self[1..-1].camelize
    end
  end
end

if __FILE__ == $0
  Opts = GetoptLong.new(
    [ '--interface',     '-i', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--interface-arg', '-j', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--ai',            '-a', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--ai-arg',        '-b', GetoptLong::REQUIRED_ARGUMENT ] )

  # defaults
  interface = 'text'
  ai = 'random'
  iface_args, ai_args = [], []

  Opts.each do |opt, arg|
    case opt
      when '--interface';     interface = arg
      when '--interface-arg'; iface_args << arg
      when '--ai';            ai = arg
      when '--ai-arg';        ai_args << arg
    end
  end

  begin
    require "interface_#{interface}"
    require "ai_#{ai}"

    iface_class = Hangman::Interface.const_get(interface.camelize)
    ai_class    = Hangman::AI.const_get(ai.camelize)

    iface = iface_class.new(*iface_args)
    ai = ai_class.new(*ai_args)

    raise 'Bad interface' unless Hangman::Interface.looks_ok?(iface)
    raise 'Bad AI' unless Hangman::AI.looks_ok?(ai)

    Hangman::Game.new(iface, ai).run
  rescue LoadError => le
    missing = /\-\- (.*)$/.match(le.message)[1]
    $stderr.puts "Can't find #{missing}"
  end
end
