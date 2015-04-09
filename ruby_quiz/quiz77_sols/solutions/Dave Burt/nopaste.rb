#
# NoPaste Uploader
#
# A response to Ruby Quiz #77 [ruby-talk:190588]
#
# nopaste.rb - a command-line interface to http://rafb.net/paste
# Usage: nopaste.rb [options]
# Options:
#    -l, --lang LANGUAGE              Language of snippet (default Plain Text)
#                                     C89, C, C++, C#, Java, Pascal, Perl, PHP,
#                                     PL/I, Python, Ruby, SQL, VB, Plain Text
#    -n, --nick NICKNAME              Your nickname (9 char max)
#    -d, --desc DESCRIPTION           Description of the snippet (50 char max)
#    -t, --cvt-tabs [SPACES]          Convert tabs to spaces (default No)
#                                     No, 2, 3, 4, 5, 6, 7, 8
#    -u, --rubyurl                    Shorten the URL using rubyurl.com
#    -a, --agree-to-terms             Agree to the Terms of Use (mandatory)
#    -s, --show-terms                 Show the Terms of Use
#    -h, --help                       Show this message
#
# Author: dave@burt.id.au
# Created: 29 Apr 2006
# Last modified: 29 Apr 2006
#

require 'optparse'
require 'net/http'
require 'facet/string/line_wrap'

module NoPaste

  module Options
    LIST = {
      :lang => %w[ C89 C C++ C# Java Pascal Perl PHP PL/I Python Ruby SQL VB
                   Plain\ Text ],
      :cvt_tabs => %w[ No 2 3 4 5 6 7 8 ],
    }
    DEFAULT = {
      :lang => "Plain Text",
      :nick => "",
      :desc => "",
      :cvt_tabs => "No"
    }
  end

  module Server
    HOST = "rafb.net"
    PATH = "/paste/paste.php"
    REFERER = "http://rafb.net/paste/index.php"
  end

  #
  # Return the Terms of Use from the website as plain text.
  #
  def terms
    @terms ||= Net::HTTP.get("rafb.net", "/paste/terms.html")
    # return text inside the div with class "content_body", without HTML tags.
    @terms[%r{<div class="content_body">.*?</div>}m].gsub(%r{<.*?>}m, "").strip
  end

  #
  # Process command-line options, returning the resulting options as a hash.
  #
  def options(argv = ARGV)
    return @options if @options

    @options = Options::DEFAULT.dup

    opts = OptionParser.new do |opts|
      opts.banner =
        "nopaste.rb - send text to http://rafb.net/paste\n" \
        "Usage: nopaste.rb [options] [file(s)]"

      opts.separator "Options:"

      opts.on("-l", "--lang LANGUAGE", Options::LIST[:lang],
              "Language of snippet (default #{Options::DEFAULT[:lang]})",
              *Options::LIST[:lang].join(", ").split(/(?=PL)/)) do |lang|
        @options[:lang] = lang
      end
      opts.on("-n", "--nick NICKNAME", "Your nickname (9 char max)") do |nick|
        @options[:nick] = nick[0, 9]
      end
      opts.on("-d", "--desc DESCRIPTION",
              "Description of the snippet (50 char max)") do |desc|
        @options[:desc] = desc[0, 50]
      end
      opts.on("-t", "--cvt-tabs [SPACES]", Options::LIST[:cvt_tabs],
              "Convert tabs to spaces (default #{Options::DEFAULT[:cvt_tabs]})",
              *Options::LIST[:cvt_tabs].join(", ")) do |spaces|
        @options[:cvt_tabs] = spaces || "8"
      end
      opts.on("-u", "--rubyurl",
              "Shorten the URL using rubyurl.com") do |rubyurl|
        @options[:rubyurl] = rubyurl
      end
      opts.on("-a", "--agree-to-terms",
              "Agree to the Terms of Use (mandatory)") do |agree|
        @options[:agree_to_terms] = agree
      end
      opts.on_tail("-s", "--show-terms", "Show the Terms of Use") do
        puts terms
        exit
      end
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    begin
      opts.parse! argv
    rescue OptionParser::ParseError => e
      STDERR.puts e, opts
      exit
    end

    unless @options[:agree_to_terms]
      STDERR.puts "missing mandatory argument: --agree-to-terms", opts
      exit
    end

    @options
  end

  #
  # Paste a snippet on http://rafb.net/paste and return the URL.
  #
  # text may not be empty.
  #
  # Valid options are:
  #   :lang (required)
  #   :nick
  #   :desc
  #   :cvt_tabs (required)
  #   :agree_to_terms
  #
  def paste(text, options)
    text = text.to_str
    raise ArgumentError, "text is empty" if text.empty?
    raise ArgumentError, "missing required option" unless options[:lang] &&
                                                          options[:cvt_tabs]
    req = Net::HTTP::Post.new(Server::PATH)
    req.set_form_data options.merge(:text => text)
    req['referer'] = Server::REFERER
    res = Net::HTTP.start(Server::HOST) do |http|
      http.request req
    end
    "http://" + Server::HOST + res['location']
  end

  extend self
end

module RubyUrl
  #
  # Return a short URL that will redirect to the given URL using rubyurl.com
  #
  def shorten(url)
    res = Net::HTTP.get_response("rubyurl.com",
                                 "/rubyurl/remote?website_url=#{url}")
    raise unless res['location']
    "http://rubyurl.com/" + res['location'][/\w+$/]
  end
  extend self
end


if $0 == __FILE__
  opts = NoPaste.options
  url = NoPaste.paste(ARGF.read, opts)
  url = RubyUrl.shorten(url) if opts[:rubyurl]
  puts "Your snippet has been uploaded:\n #{url}"
end
