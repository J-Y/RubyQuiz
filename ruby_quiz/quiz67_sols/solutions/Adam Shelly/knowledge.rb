#-------Knowledge.rb
#
class Object
  def attribute *names, &block
    names.each do |name|
      attribute *name.map{|k,v|[k,v]} and next if name.kind_of? Hash
      name,v = name
      class_eval "def #{name};"+
            "@#{name}=(defined?(@#{name}) ? @#{name} : #{name}_init_); end"
      class_eval "def #{name}?; !(self.#{name}.nil?); end"
      class_eval "def #{name}=(v); @#{name}=v; end"
      private; define_method("#{name}_init_", block || proc {v})
    end
  end
end
