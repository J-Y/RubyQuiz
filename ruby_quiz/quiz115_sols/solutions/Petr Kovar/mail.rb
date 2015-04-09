#!/usr/bin/env ruby

require 'open-uri'
require 'cgi'


# get args
uri, dir = ARGV
unless uri
  puts "usage: mail.rb <uri> [dir]"
  exit 1
end
uri = "http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/#{uri}" if uri.to_i > 0
dir = '.' if !dir


# parse given mail
def parse( mail )
  files = []

  # for each attachment
  mail.split(/^--.*?\n/m).each do |attachment|
    # try to find encoding, filename and content of file
    attachment =~ /Content-Transfer-Encoding:\s*(\S+)/
    enc = $1
    attachment =~ /Content-Disposition:\s*attachment;\s*filename="?([^"\n]+)"?.*?\n\n(.*)/m
    fname, content = $1, $2

    # skip if something goes wrong
    next unless fname and enc and content

    # decoding content
    # at first we expect it's plain
    decoded = content

    # if it was wrong expectation handle it now
    case enc
    when 'quoted-printable'
      # remove html markups they haven't space
      # to live here, it's encoded, right?
      decoded = decoded.gsub(/<.*?>/, '')

      # unqote it using wanderful unpack function
      decoded = decoded.unpack("M*")
    when 'base64'
      decoded = decoded.unpack("m*")
    end

    files << { :fname => fname, :content => decoded }
  end

  files
end


# download mail
mail = ''
puts "Downloading #{uri}"
open(uri, 'r') { |f| mail = CGI.unescapeHTML(f.read) }

# parse out files
files = parse mail

# save files
unless files.size == 0
  # create target dir
  Dir::mkdir(dir) unless File.directory?(dir)

  # save attachments
  files.each do |file|
    path = "#{dir}/#{file[:fname]}"
    puts "Saving file #{path}"
    File.open(path, "w") do |f|
      f << file[:content]
    end
  end
else
  puts "No files attached."
end
