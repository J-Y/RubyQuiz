require 'singleton'

#the Blank class is shamelessly stolen from the Criteria library
class Blank
  mask    = ["__send__", "__id__", "inspect", "class", "is_a?", "dup", 
  "instance_eval"];
  methods = instance_methods(true)

  methods = methods - mask

  methods.each do
    | m |
    undef_method(m)
  end
end

#this is a very blank class that intercepts all free
#functions called within it.
class SExprEvalBed < Blank
   include Singleton
   def method_missing (name, *args)
      SExpr.new(name, *args)
   end
end

#this is used internally to represent an s-expression.
#I extract the array out of it before returning the results
#because arrays are easier to work with. Nevertheless, since I could use
#an s-expression class as the result of certain evaluations, it didn't
#make sense to override standard array methods
#
#other built-in classes weren't so lucky
class SExpr
   def initialize(*args)
     @array=args
   end
   attr_accessor :array
   def method_missing(name,*args)
      SExpr.new(name,self,*args)
   end
   def coerce(other)
      [SQLObj.new(other),self]
   end
   def ==(other)
      SExpr.new(:==,self,other)
   end
   def to_a
      return @array.collect do |x|
	 if x.is_a?(SExpr)
	    x.to_a
	 elsif x.is_a?(SQLObj)
	    x.contained
	 else
	    x
	 end
      end
   end
end

#this is used for wrapping objects when they get involved in
#coercions to perform binary operations with a Symbol
class SQLObj
   def initialize(contained)
      @contained=contained
   end
   attr_accessor :contained
   def method_missing (name,*args)
      SExpr.new(name,self,*args)
   end
   def ==(other)
      SExpr.new(:==,self,other)
   end
end

class Symbol
   def coerce(other)
      #this little caller trick keeps behavior normal
      #when calling from outside sxp
      if caller[-2]=~/in `sxp'/
	 [SQLObj.new(other),SQLObj.new(self)]
      else
	 #could just return nil, but then the
	 #text of the error message would change
	 super.method_missing(:coerce,other)
      end
   end
   def method_missing(name, *args)
      if caller[-2]=~/in `sxp'/
	 SExpr.new(name,self,*args)
      else
	 super
      end
   end
   alias_method :old_equality, :==
   def ==(other)
      if caller[-2]=~/in `sxp'/
	 SExpr.new(:==,self,other)
      else
	 old_equality(other)
      end
   end
end

def sxp(&block)
   r=SExprEvalBed.instance.instance_eval(&block)
   if r.is_a?(SExpr)
      r.to_a
   elsif r.is_a?(SQLObj)
      r.contained
   else
      r
   end
end

require 'irb/xmp'

xmp <<-"end;"
sxp{max(count(:name))}
sxp{count(3+7)}
sxp{3+:symbol}
sxp{3+count(:field)}
sxp{7/:field}
sxp{:field > 5}
sxp{8}
sxp{:field1 == :field2}
sxp{count(3)==count(5)}
sxp{3==count(5)}
7/:field rescue "TypeError"
7+count(:field) rescue "NoMethodError"
5+6
:field > 5 rescue "NoMethodError"
end;
