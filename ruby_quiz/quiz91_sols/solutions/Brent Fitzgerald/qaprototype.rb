module Friendly

  def method_missing name
    @_new_methods ||= Hash.new
    unless @_new_methods.has_key? name
      prompt_for_definition name
    end
    eval @_new_methods[name]
  end

  def prompt_for_definition name
    puts "It appears that #{name} is undefined."
    puts "Please define what I should do (end with a blankline):"
    @_new_methods[name] = ""
    while $stdin.gets !~ /^\s*$/
      @_new_methods[name] << $_
    end
  end

  def added_methods
    @_new_methods.keys
  end

  def added_method_definitions
    @_new_methods.map {|k,v|
      s = "def #{k}\n  "
      v.rstrip!
      s << v.gsub("\n", "\n  ")
      s << "\nend"
    }
  end

end
