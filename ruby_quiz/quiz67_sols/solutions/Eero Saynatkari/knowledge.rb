# knowledge.rb
class Module
  def attribute(*args, &block)
    # Normalise
    args = args.inject([]) {|memo, arg|
             if arg.kind_of? Hash
               arg.map {|k,v| memo << [k, (block or lambda {v})]}; memo
             else
               memo << [arg, (block or lambda {instance_variable_get "@#{arg}"})]
             end
           }

    # Generate
    args.each {|name, block|
      # Retrieval
      define_method("#{name}")  {instance_variable_get "@#{name}" or instance_eval &block}
      # Query
      define_method("#{name}?") {send "#{name}"}

      # Assignment
      define_method("#{name}=") {|value|
        # Generate a simple accessor to avoid problems with nils and defaults
        class << self; self; end.send 'define_method', "#{name}", lambda {value} unless value
        instance_variable_set "#{name}", value
      }
    }
  end                    # attribute
end                      # class Module
