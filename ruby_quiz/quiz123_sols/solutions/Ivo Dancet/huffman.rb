#! /usr/local/bin/ruby

class Huffman
 attr_accessor :tree, :encoded

 def initialize
   @encoded, @tree = nil
   @line = ""
 end

 def encode( line )
   @line = line
   chars = line.split("")
   uniq = chars.uniq

   counts = []
   uniq.each do |char|
     counts << { :char => char, :count => chars.select{ |x| x == char }.length }
   end

   counts.sort!{ |x,y| x[:count] <=> y[:count]  }.reverse!

   @tree = {}
   counts.each_with_index do |char_hash,i|
     char = char_hash[:char]
     if i == counts.length-1
       @tree[char] = "1"*i
       break
     end
     @tree[char] = "1"*i+"0"
   end

   @encoded = line.split("").collect { |x| @tree[x] }.join("")
   @encoded += @tree[counts[1][:char]]
   @encoded += "0" * (8-@encoded.length%8) if @encoded.length%8 != 0

   return self
 end

 def decode( encoded, tree )
   @encoded = encoded

   @tree = tree

   @encoded.gsub!(/ |\n/, "")

   encoded = @encoded.dup
   encoded.slice!((encoded.reverse.index("01")*-1)-2..-1) # slice of extra character(s)
   loop do
     begin
       part = encoded.slice!(0..encoded.index("0"))
       @line << @ tree.select{ |key, value| value == part }[0][0]
     rescue NoMethodError
       encoded = part + encoded
       code = @tree.select{ |key, value| !value.include? "0" }[0][1]
       begin
         part = encoded.slice!(0..encoded.index(code)+code.length-1)
         @line << @tree.select{ |key, value| value == part }[0][0]
       rescue
         break
       end
     rescue ArgumentError
       break
     end

   end
 end

 def inspect
   inspect = [ "Encoded:"]
   inspect << @encoded.scan(/.{8}|.*$/).join(" ").scan(/.{45}|.*$/).join("\n")
   inspect << "Encoded Bytes:"
   inspect << byte_n_new = @encoded.length/8
   inspect << ""
   inspect << "Original:"
   inspect << @line
   inspect << "Original Bytes:"
   inspect << byte_n = @line.each_byte{}.length
   inspect << "compression: #{((byte_n-byte_n_new).to_f/byte_n.to_f*100).round}%"
   inspect << ""
   inspect << @ tree.inspect
   return inspect.join("\n")
 end
end

@huffman = Huffman.new

unless $*[0] == "-d"
 @huffman.encode($*.join(" "))
 puts @huffman.inspect
else
 puts "tree: "
 tree = eval STDIN.gets.chomp
 puts "encoding: "
 encoding = STDIN.gets.chomp
 @huffman.decode(encoding, tree)
 puts @huffman.inspect
end
