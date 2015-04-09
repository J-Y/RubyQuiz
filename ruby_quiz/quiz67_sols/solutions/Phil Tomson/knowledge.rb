#knowledge.rb
class Module
  def attribute(h_or_s, &b)
    if h_or_s.class == Hash
      str, val = h_or_s.keys[0].to_s, h_or_s.values[0]
    elsif h_or_s.class == String
      str, val = h_or_s.to_s, 0
    end
    if block_given?
      val = :init_block
      define_method(val, &b)
    end
    class_eval "def #{str}; @#{str}||=#{val} ; end"
    class_eval "def #{str}=(val); @#{str}=val; end"
    class_eval "def #{str}?; @#{str} ? true : false ; end"
  end
end
