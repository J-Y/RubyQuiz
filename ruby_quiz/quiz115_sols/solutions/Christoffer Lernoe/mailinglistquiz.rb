#!/usr/bin/env ruby -w  
                                                                  
require 'getoptlong'                                               
require "net/http"    
require "base64"                                                                            

opts = GetoptLong.new([ '--help', '-h', GetoptLong::NO_ARGUMENT],
                      [ '--path', '-p', GetoptLong::REQUIRED_ARGUMENT],
                      [ '--url', '-u', GetoptLong::REQUIRED_ARGUMENT],
                      [ '--debug', '-d', GetoptLong::NO_ARGUMENT])
               
def print_usage_and_exit
  puts "Usage: #{File.basename($PROGRAM_NAME)} [switches] message-id"
  puts "  -p directory     set save directory to directory"
  puts "  -u url           set url to use to url"
  puts "  -d               display all decoded data as it is read"
  exit 0
end
                                                              
class String                               
  
  def strip_html
    string.dup.strip_html!
  end
  
  def decode_quoted_printable                                
    decoded_string = gsub(/=../) { |code| code[1..2].hex.chr }
    strip_last = decoded_string.rstrip             
    strip_last[-1] == ?= ? strip_last.chop! : decoded_string
  end  
  
  def strip_html!
    gsub!(/<.*?>/, '')   
    gsub!(/&.*?;/) do |match| 
      case match
      when "&amp;" then '&'
      when "&quot;" then '"'
      when "&gt;" then '>' 
      when "&lt;" then '<'   
      when /&#\d+;/ then match[/(\d)+/].to_i.chr  
      when /&#x[0-9a-fA-F]+;/ then match[/[0-9a-fA-F]+/].hex.chr
      else match   
      end
    end
    self
  end                                            
  
end  
  
class WaitingState
  def process(line)          
    return self unless line =~ /^--/
    HeaderReadingState.new(line.strip)
  end
end                

WAITING_STATE = WaitingState.new

# State reading content description                                              
class HeaderReadingState
  
  def initialize(line)     
    @line = line.strip
    @data = {}
    @entry = nil
  end
  
  def process(line)
                               
    line.strip!
    
    # Ignore this attachment if we only have content lines.    
    return WAITING_STATE if line[@line]
    
    # Switch to reading attachment-data when we encounter an empty line. 
    return AttachmentParsingState.new(@line, @data) if line.empty?         
    
    # If we have an entry-header, handle this.
    if line =~ /.*:/
      @entry = line.slice!(/^.*:/)
      @entry.chop!                   
    end
    
    # Invalid attachment
    return WAITING_STATE if @entry.nil? && !line.empty?
                                      
    unless line.empty? then
      entry = @entry.downcase
      data = line.strip    
      if data[-1] == ?;                                                                  
        # More data on next line, so just chop the ; and keep the same entry
        data.chop!
      else                                                                  
        # Last data for this entry, so make sure next line has an entry.
        @entry = nil
      end                                                               
      # Data for each entry is stored as an array.
      @data[entry] = (@data[entry] || []) + data.split(/;/).collect { |part| part.strip }
    end 
    
    # Stay in this state       
    self  
    
  end                   
  
end


                
# State for reading attachment content.
class AttachmentParsingState           

  IDENTITY_DECODING = lambda { |string| string }

  QUOTED_PRINTABLE_DECODING = lambda { |string| string.decode_quoted_printable }

  BASE64_DECODING = lambda { |string| Base64.decode64(string) }

  ENCODINGS = { 'base64' => BASE64_DECODING,
                'quoted-printable' => QUOTED_PRINTABLE_DECODING }
  
  def initialize(line, data)
    @line = line                                         
    
    # Determine the encoding of the content.
    encoding = ((data["content-transfer-encoding"] || []).first || "none").downcase                              
    
    # Select a decoding and default to identity decoding.
    @decoding = ENCODINGS[encoding.downcase]
    
    # Check content-disposition if this is an attachement. 
    # If so, extract the filename. 
    disposition = data["content-disposition"]
    if disposition 
      @filename = parse_filename(disposition)
      puts "Found attachment #{@filename} with encoding '#{encoding}'." if @filename
      puts "No decoder found for '#{encoding}' - decoding turned off." unless @decoding                           
    else
      @filename = nil
    end       
    
    @data = ""
  end   
  
  # Parse out a possible filename from content-disposition.
  def parse_filename(disposition)
    return nil unless disposition.member?("attachment")        
    filename = disposition.find("") { |value| value =~ /filename/ }
    filename.slice!("filename=")
    filename.strip!
    filename = eval(filename) if filename =~ /\".*\"/ 
    filename.empty? ? nil : filename
  end        
      
  def store_attachment
    if @filename then               
      filename = File.join($file_path, @filename)
      if File.exist? filename
        puts "Extraction done: #{filename} already exists - skipping."
      else
        File.open(filename, "w+") { |file| file.print @data }
        puts "Extraction done: Attachment saved as '#{filename}'"
      end
    end            
  end
  
  # Process a line
  def process(line)
               
    if line[@line]
      # store the data we got this far.
      store_attachment
      
      # We hit a delimiter, so go back to header reading state.
      return HeaderReadingState.new(line)
 
    end
          
    # Decode and store data.
    decoded = @decoding ? @decoding.call(line) : line 
    print decoded if $debug
    @data << decoded
      
    # stay in this state
    self
  
  end   
  
end
                                         

def save_attachment(host, path, index)
  state = WAITING_STATE 
  Net::HTTP.get(host, path + index.to_s).strip_html!.each do |str|
    state = state.process(str)
  end
end
     
$file_path = "." 
$debug = false
host = "blade.nagaokaut.ac.jp"
path = "/cgi-bin/scat.rb/ruby/ruby-talk/"

opts.each do |opt, arg|
  case opt
  when '--help' 
    print_usage_and_exit
  when '--path'
    if File.directory?(arg)
      $file_path = arg
    else
      puts "Illegal path '#{arg}' - Aborting."
      exit 0
    end   
  when '--debug'
    $debug = true
  when '--url'
    url = arg.gsub(/.*:\/\//, '')
    path = url[/\/.*$/]
    path += "/" unless path[-1] == ?/
    url.slice!(path)
    host = url
  end
end

print_usage_and_exit if ARGV.length != 1

message_id = ARGV.first.to_i

save_attachment(host, path, message_id)