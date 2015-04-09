require "yaml"
Abbreviations = { "ppl"  => "people",
                  "btwn" => "between",
                  "ur"   => "your",
                  "u"    => "you",
                  "diff" => "different",
                  "ofc"  => "of course",
                  "liek" => "like",
                  "rly"  => "really",
                  "i"    => "I",
                  "i'm"  => "I'm" }

def fix_abbreviations text
  Abbreviations.each_key do |abbrev|
    text = text.gsub %r[(^|(\s))#{abbrev}((\s)|[.,?!]|$)]i do |m|
      m.gsub(/\w+/, "#{Abbreviations[abbrev]}")
    end
  end
  text
end

def capitalize_proper_nouns text
  if not File.exists?("proper_nouns.yaml")
    make_capitalize_proper_nouns_file
  end
  proper_nouns = YAML.load_file "proper_nouns.yaml"
  text = text.gsub /\w+/ do |word|
    proper_nouns[word] || word
  end
  text
end

def make_capitalize_proper_nouns_file
  words = File.read("/Users/curi/me/words.txt").split "\n"
  lowercase_words = words.select {|w| w =~ /^[a-z]/}.map{|w| w.downcase}
  words = words.map{|w| w.downcase} - lowercase_words
  proper_nouns = words.inject({}) { |h, w| h[w] = w.capitalize; h }
  File.open("proper_nouns.yaml", "w") {|f| YAML.dump(proper_nouns, f)}
end

def capitalize text
  return "" if text.nil?
  text = fix_abbreviations text
  text = text.gsub /([?!.-]\s+)(\w+)/ do |m|
    "#$1#{$2.capitalize}"
  end
  text = text.gsub /(\n)(\w+)/ do |m|
    "#$1#{$2.capitalize}"
  end
  text = text.gsub /\A(\w+)/ do |m|
    "#{$1.capitalize}"
  end
  text = text.gsub %r[\sHttp://] do |m|
    "#{$&.downcase}"
  end
  text = capitalize_proper_nouns text
  text
end

puts capitalize(ARGF.read)
