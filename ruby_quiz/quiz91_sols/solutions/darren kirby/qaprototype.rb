module MethodMaker

  def method_missing(method_name, *args)
    @imethods = {}
    puts "No such method: #{method_name}"
    # It might be a simple typo...
    # so give a chance to bail out.
    print "Care to define #{method_name}? (y/n) "
    if $stdin.gets.chomp == "y" # 'y'
      prompt_method(method_name, args)
    else
      raise NoMethodError, "#{method_name}"
    end
  end

  def prompt_method(name, args=nil) 
    puts "Enter method definition ([ctrl-d] when done):"
    meth = "def #{name}(#{args ? args.join(", ") : ""})"
    while $stdin.gets
      meth += $_
    end
    meth += "end"
    meth = meth.gsub("\n",";")
    @imethods["#{name}"] = meth
    eval meth
  end

  def print_method(name)
    meth_Array = @imethods[name].split(";")
    puts meth_Array[0]
    meth_Array[1..meth_Array.size-2].each { |line| puts "  #{line}" }
    puts meth_Array[-1]
  end
end
