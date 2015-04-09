class Object ; alias :__instance_eval :instance_eval ; end
class Array  ; alias :__each :each ; end

[Object, Kernel, Symbol, Fixnum, Bignum, Float, NilClass, FalseClass,
                         TrueClass, Hash, Array, String].__each do |clz|
  clz.class_eval do
    instance_methods.__each do |m|
      undef_method m unless /^__|^inspect$|^to_(s(?:tr)?|a(?:ry)?)$/.match(m)
    end
    def method_missing(sym, *args); [sym, self, *args]; end
    def to_ary; [self]; end     # needed by every class in this world
  end
end

# A special method_missing on the main object handles 'function' calls
class << self;  def method_missing(sym, *args); [sym, *args]; end; end

__instance_eval &@blk

__END__
