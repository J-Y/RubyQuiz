# An mostly-compatible OpenStruct replacement that is, oddly, faster than 
# OpenStruct some of the time, and crucially allows us to use Object method
# names for struct members. Needed to pass Ara's test case. To use, just
# pass it to to_ostruct:
#
#   ds = {:class => 1, :method => 2}.to_ostruct(DumbStruct)
#   
class DumbStruct  
  alias :__iv_set__ :instance_variable_set
  alias :__class__ :class
  instance_methods.each do |m| 
    undef_method(m) unless m =~ /^(__|method_missing|inspect|to_s)|\?$/
  end

  def initialize(hsh = {})
    hsh.each { |k,v| method_missing("#{k}=", v) }
  end
  
  def method_missing(name, *args, &blk)
    if (name = name.to_s) =~ /[^=]=$/
      name = name[0..-2]
      __iv_set__("@#{name}", args.first)
      (class << self; self; end).class_eval { attr_accessor name }
    else
      super
    end
  end
end

