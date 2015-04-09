class DictionaryMatcher < Array
 attr_reader :options

 def initialize(words = [], options = nil, lang = nil)
   @options, @kcode = options, lang
   super words
 end

 def =~(obj)
   collect { |word| obj =~ Regexp.new(word, @options, @kcode) }.compact.first
 end
 alias_method :===, :=~
 alias_method :match, :=~

 def casefold?
   options & Regexp::IGNORECASE
 end

 def kcode
   Regexp.new('', @options, @kcode).kcode
 end

 def to_s
   join '|'
 end
 alias_method :source, :to_s

 def inspect
   Regexp.new('REPLACE', @options, @kcode).inspect.sub('REPLACE', to_s)
 end
end

class String
 alias_method :match_object, :=~

 def =~(obj)
   result = match_object(obj)
   obj.is_a?(DictionaryMatcher) ? !result.nil? : result
 end
end
