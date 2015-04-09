class DictionaryMatcher < Array
 alias_method :===, :=~
 alias_method :match, :=~

 def initialize(default = [], options = nil)
   super(default)

   unless options.nil? or options.is_a? Fixnum
     options = Regexp::IGNORECASE
   end
   @regexp_options = options
 end

 def =~(string)
   self.map{|e| Regexp.new(e, @regexp_options) =~ string }.compact.min
 end
end
