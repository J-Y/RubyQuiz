#!/usr/bin/ruby
require 'net/http'
require 'uri'

class NoPaste
  attr_reader :answer
 
  def initialize( params={"lang"=>"Ruby","nick"=>"Myself", "desc"=>"test","cvt_tabs"=>"No","text"=>"fetch","submit"=>"Paste" },
                      uri='http://rafb.net/paste/paste.php',
                      base_uri='http://rafb.net'                  
                    )
    @uri=uri
    @base_uri=base_uri
    @params=params
    @answer=fetch_post_rafbe
  end
 
  def fetch_post_rafbe
    response=Net::HTTP.post_form(URI.parse(@uri),@params)
    begin
      raise "Something went wrong while posting" unless response['location']
    rescue
      puts $!,"\n"
      exit
    end
    @base_uri+response['location']
  end
 
  def rubyurl
    puts "Compressing at rubyurl"
    uri="http://rubyurl.com/rubyurl/remote?website_url=#{@answer}"
    response=Net::HTTP.get_response(URI.parse(uri))
    begin
      raise "Something went wrong while posting" unless response['location']
    rescue
      puts $!,"\n"
      exit
    end
    response['location'].gsub("rubyurl/show/","")
  end
end

if __FILE__ == $0
  require 'optparse'
  options={'lang'=>"Ruby",'nick'=>"myself",'desc'=>"",
               'text'=>"", 'file'=>nil, 'r'=>nil,
               "cvt_tabs"=>"No","submit"=>"Paste"  }
  opts=OptionParser.new do |opts|
    opts.banner="Posts a code snippet to rafb.net and returns the address\n"\
                      "so you can show it to your friends on IRC\n\n"\
                      "Usage: posttorafb [OPTIONS]"
    opts.separator ""
    opts.separator "Options:"
    opts.on("-l","--lang LANGUAGE",
              "LANGUAGE category.","  Default:Ruby") do |lang|
      LANGS = %w{C89 C C++ C# Java Pascal Perl PHP PL/I Python Ruby Scheme SQL VB Plain\ Text}
      begin
        raise "Invalid Argument. Language must be one of:\n#{LANGS.join(" ")}" unless LANGS.include?(lang)
      rescue
        puts $!,"\n"
        exit
      end
      options['lang']=lang
    end
    opts.on("-n","--nick NAME",
              "NAME to post under.","  Default:myself") do |nick|
      options['nick']=nick
    end
    opts.on("-d","--desc DESCRIPTION",
              "DESCRIPTION of snippet.","  Default:blank") do |desc|
      options['desc']=desc
    end
    opts.on("-f","--file FILE",
              "FILE containing snippet.","  Default: enter from console") do |file|
      options['file']=file
    end
    opts.on("-r","--rubyurl", "Send to rubyurl.com for url shortening") do |r|
      options['r']=true
    end
    opts.on_tail("-v", "--version", "Version") do
      puts "0.0.1"
      exit
    end
    opts.on_tail("-h", "--help", "Shows this message") do
      puts opts
      exit
    end
  end

  begin
    opts.parse!
  rescue
    puts $!,"\n"
    puts opts
    exit
  end 

  if options['file'] then
    begin
      options['text']=File.open(options['file'],"r").read
      puts "Pasting snippet from file #{options['file']}"
    rescue
      puts $!,"\n"
      exit
    end
  else
    puts "Reading snippet from console, finish by entering <CTRL-Z> in a new line"
    options['text']=$stdin.read
  end

  x=NoPaste.new(options)
  puts "Stored at: #{x.answer}"
  puts x.rubyurl if options['r']
end

