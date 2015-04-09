#!/usr/bin/env ruby

require 'optparse'
require 'net/http'

# Command-Line Interface.
class Cli

 Languages = %w{C89 C C++ C# Java Pascal Perl PHP PL/I Python Ruby SQL VB Plain\ Text}
 Aliases = {"c99" => "C", "visual basic" => "VB", "text" => "Plain Text"}
 PasteUrl = "http://rafb.net/paste/paste.php"

 attr :parser
 attr :opt

 # Initialize the command-line parser and set default values for the
 # options.
 def initialize
   @opt = {
     :lang => "Plain Text",
     :nick => "",
     :desc => "",
     :tabs => "No",
     :help => false}
   @parser = OptionParser.new do |cli|
     cli.banner += " [file ...]"
     cli.on('-l','--lang=L', 'select language') { |s|
       l = s.downcase
       opt[:lang] =
       if Aliases.include?(l) then
         Aliases[l]
       else
         Languages.find(proc{ raise OptionParser::InvalidArgument,l }) { |x| x.downcase == l}
       end
     }
     cli.on('-n', '--nick=NAME', 'use NAME as nickname') { |s| opt[:nick] = s}
     cli.on('-d', '--desc=TEXT', 'use TEXT as description') { |s| opt[:desc] << s }
     cli.on(      '--tabs=N', Integer, 'expand tabs to N blanks (N >= 0)') {|n|
       raise OptionParser::InvalidArgument, n unless n>=0
       opt[:tabs] = n
     }
     cli.on('-h', '--help', 'show this information and quit') { opt[:help] = true }
     cli.separator ""
     cli.separator "Languages (case insensitive):"
     cli.separator " "+(Languages+Aliases.keys).map{|x|x.downcase}.sort.join(",")
   end
 end

 # Post the given text with the current options to the given uri and
 # return the uri for the posted text.
 def paste(uri, text)
   response = Net::HTTP.post_form(
     uri,
     { "lang" => opt[:lang],
       "nick" => opt[:nick],
       "desc" => opt[:desc],
       "cvt_tabs" => opt[:tabs],
       "text" => text,
       "submit" => "Paste" })
   uri.merge response['location'] || raise("No URL returned by server.")
 end

 # Parse the command-line and post the content of the input files to
 # PasteUrl.  Standard input is used if no input files are specified
 # or whenever a single dash is specified as input file.
 def run
   parser.parse!(ARGV)
   if opt[:help]
     puts parser.help
   else
     puts paste(URI.parse(PasteUrl), ARGF.read)
   end
 rescue OptionParser::ParseError => error
   puts error
   puts parser.help()
 end

end

if __FILE__ == $0
 Cli.new.run
end

=begin rdoc

:section: A few remarks

The part of this script that actually deals with the http service is
rather short, entirely contained in Cli#paste.

Most of the code sets up the command-line interface so that the user
can specify options such as a nickname, a description, tab expansion,
and the language used for (a rather discreet) syntax highlihting.

A summary of the command-line syntax can be obtained by typing

cat2rafb --help

on the command line or by

require 'cat2rafb'
cli = Cli.new;
puts cli.parser.help

in ruby.

=end
