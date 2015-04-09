#!/usr/bin/ruby -W2

require 'open-uri'
require 'cgi'

module URI
  # Builds a query string from the specified (key => value) hash
  def self.build_query(data)
    data.map do |key, value|
      [CGI.escape(key.to_s), CGI.escape(value.to_s)].join("=")
    end.join("&")
  end
end



module RAFB
  extend self

  class RAFBError < StandardError; end
  class TooFastError < RAFBError; end

  MainURI = URI("http://rafb.net/paste/") unless defined?(MainURI)
  PostURI = MainURI + "paste.php" unless defined?(PostURI)

  # Fetch page
  main_data = MainURI.read

  # Find type option HTML
  type_section = main_data[%r{<select name="lang" id="lang">(.+?)</select>}m, 1]

  # Delete commented out options
  type_section.gsub!(/<!--.*?-->/, "")

  # Parse types from type option HTML
  type_re = %r{<option value="([^"]+)"\s*((?:selected)?)[^>]*>([^<]+)</option>}
  type_data = type_section.scan(type_re)

  # Find the default type
  DefaultType = type_data.find do |(value, selected, label)|
    selected != ""
  end.last unless defined?(DefaultType)

  # Build {label => value} map from type data
  TypeMap = type_data.inject({}) do |map, (value, selected, label)|
    map.merge(label => value, value => value)
  end unless defined?(TypeMap)
  Types = TypeMap.keys.sort unless defined?(Types)

  # Posts the supplied data to RAFB and returns the resulting URI.
  # type has to be an element of Types and defaults to DefaultType.
  # You can supply an optional nickname, description and tab conversion size.
  # If you don't supply a tab conversion size tabs are left untouched.
  # Can raise a RAFB::TooFastError if you repost too frequently.
  def post(data, type = DefaultType, nickname = "", description = "", tab_size = nil)
    unless Types.include?(type)
      raise(ArgumentError, "Unsupported type %p" % type)
    end

    convert_tabs = tab_size || "No"
    query = URI.build_query(
      "lang" => TypeMap[type],
      "nick" => nickname,
      "desc" => description,
      "cvt_tabs" => convert_tabs,
      "text" => data
    )

    Net::HTTP.start(PostURI.host) do |http|
      response = http.post(PostURI.path, query,
        'content-type' => 'application/x-www-form-urlencoded')
      location = response["location"]

      if location == "/paste/toofast.html" then
        raise(TooFastError, "Posting too fast. Try reposting later.")
      else
        MainURI + location
      end
    end
  end
  alias :write :post
  alias :save :post

  # Same as RAFB.post(), but will retry when you are posting too fast.
  def retry_post(*args)
    delay = 1

    begin
      post(*args)
    rescue TooFastError => error
      sleep delay
      delay *= 2
      retry
    end
  end

  # Reads code from RAFB.
  # You can either supply a full RAFB URI or URI string or the identifier
  # as a String.
  def fetch(uri)
    unless uri.is_a?(URI)
      uri = uri.to_s

      unless uri.include?("rafb.net")
        uri = MainURI.to_s + "results/#{uri}.html"
      end

      unless uri.include?("http")
        uri = "http://" + uri
      end
    end

    uri = URI(uri.to_s.sub(/\.html$/, ".txt"))

    unless uri.host == "rafb.net"
      raise(ArgumentError, "Invalid host %p" % uri.host)
    end

    unless uri.path[%r{^/paste/results/[^/.]+\.txt$}]
      raise(ArgumentError, "Invalid path %p" % uri.path)
    end

    open(uri) { |res| res.read }
  end
  alias :read :fetch
  alias :load :fetch
end

class String
  # Posts the supplied String to RAFB and returns the resulting URI.
  def on_rafb(*more)
    RAFB.retry_post(self, *more)
  end

  # Reads a String from RAFB using the supplied url.
  def self.from_rafb(uri)
    RAFB.fetch(uri)
  end
end



module RubyURL
  extend self

  MainURI = URI("http://rubyurl.com/") unless defined?(MainURI)
  PostURI = MainURI + "/rubyurl/create" unless defined?(PostURI)

  # Posts a URI to RubyURL and returns the new URI.
  def post(uri)
    query = URI.build_query(
      "rubyurl[website_url]" => uri
    )
    data = open([PostURI, query].join("?")) { |res| res.read }
    uri_re = %r{<a href="([^"]+)">\1</a>}
    URI(data[uri_re, 1])
  end
  alias :write :post
  alias :save :post
  alias :shorten :post

  # Fetches the new URI from RubyURL and returns it.
  def fetch(uri)
    unless uri.is_a?(URI)
      uri = uri.to_s

      unless uri.include?("rubyurl.com")
        uri = MainURI.to_s + uri
      end

      unless uri.include?("http")
        uri = "http://" + uri
      end
    end

    uri = URI(uri)

    unless uri.host == "rubyurl.com"
      raise(ArgumentError, "Invalid host %p" % uri.host)
    end

    unless uri.path.include?("/go/index/")
      uri.path = "/go/index" + uri.path
    end

    unless uri.path[%r{^/go/index/[^/.]+$}]
      raise(ArgumentError, "Invalid path %p" % uri.path)
    end

    Net::HTTP.start(uri.host) do |http|
      response = http.get(uri.path)
      response["location"]
    end
  end
  alias :read :fetch
  alias :load :fetch
  alias :unshorten :fetch  
end

module URI
  # Returns this URI's RubyURL URI.
  def on_rubyurl(*more)
    RubyURL.post(self, *more)
  end

  # Constructs a URI from a RubyURL URI.
  def self.from_rubyurl(uri)
    RubyURL.fetch(uri)
  end
end



if __FILE__ == $0 then
  require 'optparse'
  require 'abbrev'

  class Array
    def groups_of(count)
      unless count > 0
        raise(ArgumentError, "Invalid count %p" % count)
      end

      ary = self.dup
      result = []
      while group = ary.slice!(0, count) and not group.empty?
        result << group
      end

      return result
    end
  end

  TypeNames = RAFB::Types.abbrev

  Options = {
    :Type => RAFB::Types.grep("Plain Text").first || RAFB::DefaultType,
    :Nickname => ENV["USERNAME"] || ENV["USER"],
    :Description => "",
    :TabSize => nil,
    :ShortenURI => true
  }

  ARGV.options do |opts|
    script_name = File.basename($0)
    id = %q$Id: cat2rafb.rb 117 2006-04-28 22:09:29Z flgr $
    version = id.split(" ")[2 .. -1].join(" ") rescue "unknown"

    opts.banner = "Usage: ruby #{script_name} [options]"

    opts.separator ""
    opts.separator "Submits code to RAFB codepaste and returns the URL."
    opts.separator ""


    opts.separator "Specific options:"

    types = RAFB::Types.map do |type|
      type.inspect
    end.groups_of(5).map do |group|
      "  " + group.join(", ") + ","
    end
    # Delete last comma
    types[-1][-1] = ""

    opts.on("--type=type", String, "-T", String,
      "Specify type of posted code.",
      "You can specify the first few characters of",
      "a type when it is clear which is meant.",
      "Possible values are:",
      *(types +
       ["Default: #{Options[:Type].inspect}"])
    ) do |type|
      if TypeNames.include?(type) then
        Options[:Type] = TypeNames[type]
      else
        raise(ArgumentError, "Invalid type %p" % type)
      end
    end

    opts.on("--nick=nick", String, "-N", String,
      "Nick name to use as author of posted code.",
      "Default: Current user (#{Options[:Nickname]})"
    ) { |Options[:Nickname]| }

    opts.on("--description=desc", "--desc=desc", "-D",
      "Description to use for posted code.",
      "Default: None"
    ) { |Options[:Description]| }

    opts.on("--tab-size=size", "--tabs=size", "-t",
      "Convert tabs to size space characters.",
      "Default: Don't convert"
    ) { |Options[:TabSize]| }

    opts.on("--no-shorten-uri", "-U",
      "Don't shorten the URI from RAFB via RubyURL."
    ) { Options[:ShortenURI] = false }

    opts.separator ""


    opts.separator "Common options:"

    opts.on_tail("-h", "--help",
      "Show this message."
    ) { puts opts; exit }
    opts.on_tail("-V", "--version",
      "Show the version of this program."
    ) { puts "#{script_name}, #{version}"; exit }

    opts.parse!
  end

  data = ARGF.read
  uri = RAFB.post(data, Options[:Type], Options[:Nickname],
    Options[:Description], Options[:TabSize])

  if Options[:ShortenURI] then
    uri = RubyURL.post(uri)
  end

  puts uri
end