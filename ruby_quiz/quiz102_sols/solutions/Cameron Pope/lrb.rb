require 'rubygems'
require 'bluecloth'
class LRB
 def parse(io, &block)
   current_state = :in_text
    io.each_line do |line|
      if current_state == :in_text
        case line
        when /^>\s?(.*)/: yield :code, $1 + "\n" if block_given?
        when /\\begin\{.*\}\s*.*/: current_state = :in_code
        else yield :text, line if block_given?
        end
      else
        case line
          when /\\end\{.*\}\s*.*/: current_state = :in_text
          else yield :code, line if block_given?
        end
      end
    end
  end
 def self.to_code(io)
   code = String.new
   LRB.new.parse(io) do |type, line|
     code << line if type == :code
   end
   return code
 end
 def self.to_markdown(io)
   doc = String.new
   LRB.new.parse(io) do |type, line|
     case type
     when :code: doc << "    " << line
     when :text: doc << line
     end
   end
   return doc
 end
  def self.to_html(io)
    markdown = self.to_markdown io
    doc = BlueCloth::new markdown
    doc.to_html
  end
end # class LRB
if $0 == __FILE__
 opt = ARGV.shift
 file = ARGV.shift
  case opt
    when '-c': puts LRB::to_code(File.new(file))
    when '-t': puts LRB::to_markdown(File.new(file))
    when '-h': puts LRB::to_html(File.new(file))
    when '-e': eval LRB::to_code(File.new(file))
    else
      usage = <<"ENDING"
Usage:
  lrb.rb [option] [file]

Options:
  -c: extract code
  -t: extract text documentation
  -h: extract html documentation
  -e: evaluate as Ruby program
ENDING
    puts usage
  end
end
