class Module
  def attribute(*objects, &block)
    objects.each { |object|
      attr = object.is_a?(Hash) ? object : {object => nil}
      symbol = attr.keys[0]
      default = block || lambda { attr[symbol] }
      define_method("#{symbol}?") { instance_eval &default }
      class_eval "alias #{symbol} #{symbol}?"
      define_method("#{symbol}=") { |value|
        instance_eval %{
           def #{symbol}?; @#{symbol}; end
           alias #{symbol} #{symbol}?
           @#{symbol} = value
           }
         }
       } 
     end 
end
