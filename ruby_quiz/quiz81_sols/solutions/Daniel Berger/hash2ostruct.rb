class Hash
  def to_ostruct(clz = OpenStruct)
    clz.new Hash[*inject([]){|ar,(k,v)|ar<< k<<(v.to_ostruct(clz) rescue v)}]
  end
end


class OpenStruct
   alias :old_init :initialize
   def initialize(hash=nil)
      old_init(hash.each{ |k,v| hash[k] = self.class.new(v) if v.is_a?(Hash) })
   end

   def new_ostruct_member(name)
      name = name.to_sym
      meta = class << self; self; end
      meta.send(:define_method, name) { @table[name] }
      meta.send(:define_method, "#{name}=""#{name}=") { |x| @table[name] = x }
   end
end
