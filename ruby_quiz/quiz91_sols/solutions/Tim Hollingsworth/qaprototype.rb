module QAPrototype

  def method_missing(meth, *args)
    arg_list = args.map {|arg| arg.class.to_s.downcase}.join(", ")
    meth_def = "def #{meth}(#{arg_list})\n"
    puts meth_def
    while (line = gets) != "end\n"
      meth_def += "  " + line
    end
    meth_def += "end\n"

    eval meth_def

    @qamethods ||= []
    @qamethods << meth_def
    nil
  end

  def qaprint
    puts @qamethods.join("\n") if @qamethods
  end
end
