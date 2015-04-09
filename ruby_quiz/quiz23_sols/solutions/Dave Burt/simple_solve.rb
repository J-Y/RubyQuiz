class String
 def to_quoted_printable(*args)
   [self].pack("M").gsub(/\n/, "\r\n")
 end
 def from_quoted_printable
   self.gsub(/\r\n/, "\n").unpack("M").first
 end
end

if __FILE__ == $0
  require 'optparse'
  
  # Look, James, I'm opt-parsing! :)
  decode_mode = false
  xml_mode = false
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename($0)} [OPTIONS]"
    opts.separator ''
    opts.separator 'Specific Options:'
    
    opts.on('-d', '--decode', 'Convert from quoted-printable to native') do
      decode_mode = true
    end
    
    opts.on('-x', '--xml', 'Quote XML special characters <, > and &',
                           '(ignored when decoding)') do
      xml_mode = true
    end
    
    opts.on('-h', '-?', '--help', 'Show this text') do
      puts opts
      exit
    end
    
    opts.separator 'The default mode encodes STDIN as quoted-printable.'
  end
  
  opts.parse! ARGV
  
  operation =
    if decode_mode
      [:from_quoted_printable]
    elsif xml_mode
      [:to_quoted_printable, QuotedPrintable::XML_PRINTABLES]
    else
      [:to_quoted_printable]
    end
  
  if decode_mode
    ARGF.binmode
  else
    STDOUT.binmode
  end
  
  ARGF.each { |line| print line.send(*operation) }
  
end
