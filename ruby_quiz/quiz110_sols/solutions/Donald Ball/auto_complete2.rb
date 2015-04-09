#!c:\ruby\bin\ruby.exe
#
# Implements auto complete for abbreviated methods
#
# Ruby Quiz 110
#
# Donald Ball 2007-01-19

require 'set'

module AutoComplete
  module ClassMethods
    attr_reader :abbrs
    def abbrev(*args)
      # TODO abbrs might be better implemented as a sorted set
      @abbrs ||= Set.new
      @abbrs += args
    end
  end
  module ObjectMethods
    def method_missing(id, *args)
      # if it is an exact match, there is no corresponding method or else it would have been called
      if self.class.abbrs.include?(id)
        super
      end
      s = id.to_s
      len = s.length
      # find all abbreviations which begin with id and have active methods
      matches = self.class.abbrs.select { |abbr| abbr.to_s[0,len] == s && respond_to?(abbr)}
      if matches.length == 0
        super
      elsif matches.length == 1
        send(matches[0], *args)
      else
        matches
      end
    end
  end
end

class Class
  include AutoComplete::ClassMethods
end

class Object
  include AutoComplete::ObjectMethods
end
