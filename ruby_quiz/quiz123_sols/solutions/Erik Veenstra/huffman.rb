class Huffman
  def self.encode(string)
    bytestream          = string.scan(/./m)

    tree                = bytestream.uniq.collect{|c1| [c1, string.scan(c1).length]}
    while tree.length > 1
      a, b, *tree       = tree.sort_by{|_, count| count}        # Not deterministic.
      tree << [[a[0], b[0]], a[1]+b[1]]
    end
    tree                = tree.shift.shift      unless tree.empty?

    path_to_char =
    lambda do |c, t|
      res = "0"+path_to_char.call(c, t[0])      if [t[0]].flatten.include?(c)
      res = "1"+path_to_char.call(c, t[1])      if [t[1]].flatten.include?(c)
      res || ""
    end

    int8_to_bits        = lambda{|i| [i].pack("C").unpack("B*").shift}
    byte_to_bits        = lambda{|c| c.unpack("B*").shift}
    table               = bytestream.uniq.inject({}){|h, c| h[c] = path_to_char.call(c, tree) ; h}
    len_table           = int8_to_bits[table.length]
    ser_table           = table.collect{|c, bs| [int8_to_bits[bs.length], bs, byte_to_bits[c]]}.flatten.join("")
    bitstring           = bytestream.collect{|c| table[c]}.join("")
    message             = len_table + ser_table + bitstring
    padding             = int8_to_bits[message.length%8 == 0 ? 0 : 8-message.length%8]

    [padding + message].pack("B*")
  end

  def self.decode(string)
    bitstring           = string.unpack("B*").shift
    bits_to_int8        = lambda{|b| [b].pack("B*").unpack("C").shift}
    bits_to_byte        = lambda{|b| [b].pack("B*")}
    read_bits           = lambda{|n| x, bitstring = bitstring[0...n], bitstring[n..-1] ; x}     # Desctructive!
    read_int8           = lambda{bits_to_int8[read_bits.call(8)]}                               # Desctructive!
    read_byte           = lambda{bits_to_byte[read_bits.call(8)]}                               # Desctructive!
    padding             = read_int8.call
    bitstring           = bitstring[0...-padding]       if padding > 0
    len_table           = read_int8.call
    len_table           = 256   if len_table == 0
    table               = (0...len_table).inject({}){|h, n| h[read_bits.call(read_int8.call)] = read_byte.call ; h}

    bitstring.scan(/#{table.keys.join("|")}/).collect{|bits| table[bits]}.join("")
  end
end

if $0 == __FILE__
  input = $stdin.read

  if ARGV.include?("-d")
    output      = Huffman.decode(input)
    $stderr.puts "Decompression: #{input.length}/#{output.length} (#{100*input.length/output.length rescue "?"}%)"
  else
    output      = Huffman.encode(input)
    $stderr.puts "Compression: #{output.length}/#{input.length} (#{100*output.length/input.length rescue "?"}%)"
  end

  $stdout.write output
end