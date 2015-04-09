Meta_value = {}

def attribute(name, &block)
  (name.is_a?(Hash) ? name : {name => nil}).each do |key, value|
    define_method(key.to_sym) do
      if Meta_value[[self, key]].nil?
        Meta_value[[self, key]] = (block_given? ? instance_eval(&block) : value)
      else
        Meta_value[[self, key]]
      end
    end
    define_method((key + "=").to_sym) {|val| Meta_value[[self, key]] = val}
    define_method((key + "?").to_sym) {not Meta_value[[self, key]].nil?}
  end
end
