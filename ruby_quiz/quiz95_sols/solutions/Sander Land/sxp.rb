class Class
  def rename_method(new_name,old_name)
      alias_method new_name,old_name
      undef_method old_name
  end
  def hide_methods
    instance_methods.each{|m| rename_method '____'.__send__('__+',m), m unless m.__send__('__=~',/^__/)  }
    define_method(:method_missing){|m,*a| SXP.new [m,self,*a] }
  end
  def restore_methods
    undef_method :method_missing
    instance_methods.each{|m| rename_method m.__send__('__[]',4..-1),m if m.__send__('__=~',/^____/) }
  end
end

HIDE_METHODS_FOR = [Fixnum,Bignum,Float,Symbol,String]
class String
  [:+,:=~,:[]].each{|m| alias_method '__'+m.to_s,m } # these methods are used by hide_methods and restore_methods
end

class Object
  def __from_sxp; self ; end
end

class SXP < Class.new{hide_methods}
  def initialize(a); @a = a; end
  def __from_sxp
    @a.map{|x| x.__from_sxp }
  end
end

class SXPGen < Class.new{hide_methods}
  def method_missing(m,*args)
    SXP.new [m,*args]
  end
end

def sxp(&b)
  HIDE_METHODS_FOR.each{|klass| klass.hide_methods }
  SXPGen.new.____instance_eval(&b).__from_sxp rescue nil
  ensure HIDE_METHODS_FOR.each{|klass| klass.restore_methods }
end