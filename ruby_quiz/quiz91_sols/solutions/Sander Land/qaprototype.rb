require 'facets'
require 'facets/core/kernel/singleton'

class Module
  public :class_variable_set, :class_variable_get  #  public in 1.9 (?)
end

module InputMethod
  def self.included(klass)
    klass.class_variable_set(:@@inputmethods, methods=Hash.new{|h,k| h[k]=[]})
    include_point = caller.first
    klass.singleton.send(:define_method,:patch!) {
      return if methods.empty?
      _, file, line = /(.*)\:(\d+)/.match(include_point).to_a
      puts "Adding methods #{methods.keys.join(',')} to #{klass}"
      contents = File.readlines(file)
   
      ix = line.to_i-1
      indent = contents[ix][/^\s*/]
      code = methods.values.join("\n").split("\n").map{|l| indent + l }.join("\n") # add indent
      contents[ix] = code + "\n\n" + contents[ix] # insert methods before include statement
      File.open(file,'w') {|f| f << contents.join }
      methods.clear
    }
    klass.singleton.send(:define_method,:patches) { methods.values.join("\n")   }
    klass.singleton.send(:define_method,:remove_patch) {|m|
      methods.delete m
      remove_method m
    }
  end

  def method_missing(method,*args)
    print "Give the method definition for #{self.class}\##{method}\nEND to force input end, display error and return nil\n> ";
    method_body = line = gets
    begin
      self.class.class_eval(method_body)
    rescue SyntaxError
      return puts("Syntax error: #{$!.message[/[^\:]+\Z/].lstrip}") if line.chomp == 'END'
      print '> '
      method_body << line=gets
      retry
    end
    self.class.class_variable_get(:@@inputmethods)[method] = method_body
    send(method,*args)
  end
end