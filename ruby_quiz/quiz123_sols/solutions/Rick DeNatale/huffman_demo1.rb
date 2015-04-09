require 'huffman'

tg = Huffman::TreeGenerator.new
tg.analyse("ABRRKBAARAA") 
codec = Huffman::Codec.new(tg.generate_tree)
puts codec.root.to_s
puts "code_pattern = #{codec.code_pattern.inspect}"

encoded = codec.encode_string("ABRRKBAARAA")
puts "encoded = #{encoded}"
puts "decoded = #{codec.decode_string(encoded, "")}"

require 'yaml'

y = YAML.dump(tg.generate_tree)
codec = Huffman::Codec.new(YAML.load(y))
puts codec.root.to_s
puts "code_pattern = #{codec.code_pattern.inspect}"

encoded = codec.encode_string("ABRRKBAARAA")
puts "encoded = #{encoded}"
puts "decoded = #{codec.decode_string(encoded, "")}"



