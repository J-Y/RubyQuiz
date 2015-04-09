require 'abbrev'

class AmbiguousExpansionError < StandardError
   attr_accessor :candidates
   def initialize(name,possible_methods)
      super("Ambiguous abbreviaton: #{name}\n"+
            "Candidates: #{possible_methods.join(", ")}")
      @candidates=possible_methods
   end
end

module Abbreviator
   def method_missing name,*args
      abbrevs=methods.abbrev
      return send(abbrevs[name.to_s],*args) if abbrevs[name.to_s]
      meths=abbrevs.reject{|key,value| key!~/^#{name}/}.values.uniq
      raise AmbiguousExpansionError.new(name, meths) if meths.length>1
      return super(name,*args)
   end
end
