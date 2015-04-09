# RubyQuiz #91 - QAPrototype

################################################################################
# QAPrototype ##################################################################
################################################################################

# This module mixes in to classes that you want to be able to handle unknown method calls
# by requesting the user to give the body of the method interactively. This tool can be
# used within IRB with `irb -rqap` and then `include QAPrototype` within the class.

module QAPrototype
  
  attr :_methods_added
  
  ################################################################################
  
  # Method was not defined, so let's get the body of the method
  def method_missing name, *args, &block
    puts "\n#{name} is undefined.\n"
    puts "Please define what I should do, starting with arguments"
    puts "this method should accept (skip and end with newline):\n\n"
    
    # get arguments
    print "def #{name} "; $stdout.flush; arguments = $stdin.gets
    
    # get method body
    method = ""
    while (print '  '; $stdout.flush; line = $stdin.gets) != "\n"
      method << "    " << line
    end
    puts "end\n"
    
    if method == ""
      puts "\nOops: you left the method empty so we didn't add it.\n\n"
      return
    end
    
    puts "\nOkay, I got it.\n\n"
    
    # now define a new method
    self.class.class_eval <<-"end;"
      def #{name} #{arguments}
        #{method}
      end
    end;
    
    # and store the results to the stack for undoes and dumps
    @_methods_added ||= []
    @_methods_added << { :name => name, :arguments => arguments.chomp, :body => method.chomp }
    
    puts "\nCalling the method now!\n\n"
    
    return self.method(name).call(*args, &block)
  end
  
  ################################################################################
  
  # Undo will take the method we've interactively defined last
  # and will remove it (undoing the last method first, and so on)
  def undo
    the_method = @_methods_added.pop
    
    if the_method.nil?
      puts "\nYou have not interactively defined any methods!\n"
      return
    end
    
    self.class.class_eval { remove_method the_method[:name] }
    
    puts "\n#{the_method[:name]} is now gone from this class.\n\n"
  end
  
  ################################################################################
  
  # Dump out the definition of the class we're working with/adding methods to
  def dump filename = nil
    body = ""
    @_methods_added.each do |method|
      body << <<-"end;"
  def #{method[:name]} #{method[:arguments]}
#{method[:body]}
  end
end;
    end
    
    klass = <<-"end;"
class #{self.class}
#{body.chomp}
end
end;
    
    if !filename.nil?
      File.open(filename, File::CREAT|File::TRUNC|File::RDWR, 0644) do |file|
        puts "\nClass was written to #{filename} successfully!\n\n" if file.write klass
      end
    else
      puts klass
    end
  end
  
  ################################################################################
  
  def added_methods
    @_methods_added
  end
  
  alias :methods_added :added_methods
  
end

################################################################################
# Help in testing... ###########################################################
################################################################################

class Foo; include QAPrototype; end

puts "\nCall #start if you want to get a head start on QAPrototype...\n\n"

def start
  puts "\nirb(prep):001:0> @f = Foo.new"
  puts "irb(prep):002:0> @f.bar\n\n"
  
  puts "For your convenience in testing, I've created a class called"
  puts "Foo and have already mixed in QAPrototype! Aren't you glad?"
  puts "And while I was at it, I went ahead and created an instance"
  puts "of Foo and put it into @f. Now we can all shout for joy!"
  puts "Heck, we even started up the conversation with method_missing!"
  
  @f = Foo.new
  @f.bar
end

# End.
