#!/usr/bin/env ruby
#

require 'net/http'
require 'strscan'
require 'cgi'

class GetAttachments
  def initialize(id)
    @id = id
    @url = "blade.nagaokaut.ac.jp"
    @params = "/cgi-bin/scat.rb/ruby/ruby-talk/" + @id
    @attachments = Array.new
  end

  def store_attachments
    # get the attachment, then store it.
    self.fetch_attachments
    self.save_attachments
  end

  def fetch_attachments
    # get the page and extract email from pre tags
    @page = Net::HTTP.get(@url, @params)
    @page =~ /\<pre\>(.+)\<\/pre\>/im
    @email = $1
    # get rid of everything before the first part separator
    # NB boundary separators assumed to start with -- No RFC guarantee this is always right.
    @email.sub!(/\A([^-]|-[^-])+/m, '')
    # create a scanner and grab header / body pairs
    @mime_scanner = StringScanner.new(@email)
    # this regex looks for a boundary line beginning -- then a line beginning Content then other header stuff then a blank line then body stuff
    # then either another of the same or a boundary then an empty line. Lookahead ?= prevents using part of next token.
    while @mime_scanner.scan(/(^--.+?\nContent.*?^\s*$)(.*?)(?=^--.+?\n(Content|^\s*$))/im) do
      attachment = Hash.new
      # translate html escapes and get rid of html mark-up that seems to creep into body, plus starting and trailing spaces
      attachment[:header] = CGI.unescapeHTML( @mime_scanner[1] )
      attachment[:body] = CGI.unescapeHTML( @mime_scanner[2].gsub(/\A\s+/,'').chomp.gsub(/\<[^\>]*\>/, '') )
      @attachments = @attachments << attachment
    end
  end

  def save_attachments
    @attachments.each do |a|
      # skip parts that aren't attachments
      next if !(a[:header] =~ /Content-Disposition:\s*attachment/i)
      # grab file name and encoding.
      # quit with error if no filename.
      if ( a[:header] =~ /filename\s*\=\s*\"?([a-z\-\_\ 0-9\.\%\$\@\!]+)\"?\s*(\n|\;)/i || a[:header] =~ /name\s*\=\s*\"?([a-z\-\_\ 0-9\.\%\$]+)\"?\s*(\n|\;)/i )
        # do above as || to favor filename over name, which may be unnecessary
        # NB hasty assumptions about file name characters
        filename = $1
      else
        puts "Could not parse filename for attachment from #{a[:header]}"
        exit 1
      end
      if ( a[:header] =~ /Content-Transfer-Encoding:\s*\"?([a-z\-\_0-9]+)\"?\s*?(\n|\;)/i )
        encoding = $1
      end
      # if the filename specifies a directory and it exists, use it. Otherwise just put in pwd.
      # NB clobbers any files with same name as attachment.
      if ( File.exist?(File.dirname(filename)) )
        file = File.new(filename, "w+")
      else
        file = File.new(filename = File.basename(filename), "w+")
      end
      # decode if necessary
      case encoding
      when /base64/i
        file << a[:body].unpack("m").first
      when /quoted-printable/i
        file << a[:body].unpack("M").first
      else
        file << a[:body]
      end
      # notify what's been done, clean up and go home
      file.close
      puts "Stored attachment from message #{@id} at #{@url} in #{File.expand_path(filename)}"
      exit 0
    end
  end
end

ARGV.each do |arg|
  @ga = GetAttachments.new(arg)
  @ga.store_attachments
end
