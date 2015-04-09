#!/usr/bin/ruby -w

require 'set'

$dict = File.readlines("dict.txt").map{|x| x.chomp}
$patterns = {}


$cipher_text = File.readlines(ARGV[0]).map{|x| x.chomp}.join(" ")
$cipher_tokens = $cipher_text.split
$cipher_token_map_sets = {}


def combine_map_sets(a, b)
  puts "combining map sets"
  return b if a.length == 0
  return a if b.length == 0

  puts "both have some members (a = #{a.length}, b = #{b.length})"
  matched = []

  com_let = common_letters(a[0], b[0])

  if com_let == 0 then
    puts "no common letters - making cartesian product"
    a.each do |as|
      b.each do |bs|
        sas = Set.new(as)
        sbs = Set.new(bs)
        matched << (sas | sbs)
      end
    end
  else
    puts "common letters: #{com_let}"
    puts "trying all 'a' maps against all 'b' maps"
    a.each do |as|
      b.each do |bs|
        sas = Set.new(as)
        sbs = Set.new(bs)
        comb_set = sas & sbs
        
        if comb_set.length == com_let then
          matched << (sas | sbs)
        end
      end
    end
  end
  return matched.map{|m| valid_map?(m)}.compact
end

def common_letters(a, b)
  a_init = Set.new(a.map{|x| x[0].chr})
  b_init = Set.new(b.map{|x| x[0].chr})
  puts "a has cipher characters: #{a_init.inspect}"
  puts "b has cipher characters: #{b_init.inspect}"
  return (a_init & b_init).length
end

def decrypt(maps)
  puts "decrypting"
  plain_texts = []
  maps.each do |map|
    plain_texts << $cipher_text.tr(*map_to_tr(map))
  end
  return plain_texts
end

def make_cipher_token_map_sets
  puts "getting maps for each cipher token"
  $cipher_tokens.each do |token|
    next if $cipher_token_map_sets.has_key?(token) #no need to solve the same token twice
    $cipher_token_map_sets[token] = map_sets(token)
    puts "#{token} has #{$cipher_token_map_sets[token].length} possible maps"
  end
  
end

def make_patterns_from_dict
  puts "making pattern dict"
  $dict.each do |word|
    p = pattern(word)
    $patterns[p] = [] unless $patterns.has_key?(p)
    $patterns[p] << word
  end
end

def map_sets(token)
  sets = []
  token_pattern = pattern(token)
  if $patterns.has_key?(token_pattern) then
    $patterns[token_pattern].each do |dict_word|
      this_set = []
      0.upto(token.length - 1) do |i|
        c = token[i].chr
        m = dict_word[i].chr
        this_set << "#{c}#{m}"
      end
      sets << Set.new(this_set)
    end
  end
  return sets
end

def map_to_tr(map_set)
  mapping = {}
  map_set.each do |map_pair|
    mapping[map_pair[0].chr] = map_pair[1].chr
  end
  cipher = ''
  plain = ''
  %w{a b c d e f g h i j k l m n o p q r s t u v w x y z}.each do |x|
    cipher << x
    if mapping.has_key?(x) then
      plain << mapping[x]
    else
      plain << '?'
    end
  end
  return cipher, plain
end

def pattern(word)
  pattern = ''
  maps = {}
  map_space = %w{a b c d e f g h i j k l m n o p q r s t u v w x y z}
  word.each_byte do |b|
    c = b.chr
    maps[c] = map_space.shift unless maps.has_key?(c)
    pattern << maps[c]
  end
  return pattern
end

def valid_map?(map)
  #make map into hash for easy testing
  mapping = {}
  map.each do |map_pair|
    c = map_pair[0].chr #cipher
    p = map_pair[1].chr #plain
    return nil if c == p #cipher cannot map to self
    return nil if mapping.has_key?(c) #cipher cannot map same cipher twice
    mapping[c] = p
  end

  cipher_count = mapping.keys.length
  plain_count = mapping.values.uniq.length
  return nil if plain_count < cipher_count #some plain was not uniq

  return map
end

#####################################################################
# The fun begins...
#
make_patterns_from_dict
make_cipher_token_map_sets

$sorted_cipher_tokens = $cipher_tokens.sort{|x, y|
  y.length <=> x.length
}
puts "sorted list of cipher tokens: #{$sorted_cipher_tokens.join(', ')}"

#seed the matched set, this is the union of all token maps that have matching map pairs 
matched_set = $cipher_token_map_sets[$sorted_cipher_tokens[0]]

1.upto($sorted_cipher_tokens.length - 1) do |i|
  new_match = combine_map_sets(matched_set,
                               $cipher_token_map_sets[$sorted_cipher_tokens[i]]
                               )
  #if nothing matched, just keep the old set? why not.
  matched_set = new_match unless new_match == []
end

puts matched_set.inspect
puts decrypt(matched_set).join("\n")
