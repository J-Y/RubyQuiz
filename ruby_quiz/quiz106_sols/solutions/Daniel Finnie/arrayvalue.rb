class ArrayValue
	instance_methods.each do |m|
		undef_method(m) unless m =~ /^_*(method_missing|send|id)_*$/
	end
	
	def initialize(origArray, origIndex)
		@origArray, @origIndex = origArray, origIndex
	end
	
	def set(newObj)
		@origArray[@origIndex] = newObj
	end
	
	def get
		@origArray[@origIndex]
	end
	
	def method_missing(method, *args)
			get.send(method, *args)
		rescue
			super
	end
	
	define_method(:'= ') {|other| set(other)}
end

class Array
	def to_av()
		ret = []
		each_index {|x| ret << ArrayValue.new(self, x) }
		ret
	end
end

__END__
% cat view.rb
class ArrayView
  class ArrayIndexRef
    def initialize( array, index )
      @array = array
      @index = index
    end

    def value
      @array[@index]
    end

    def value=(new_value)
      @array[@index] = new_value
    end
  end

  def initialize( array )
    @array = array
    @references = []
  end

  def [](*args)
    if args.length == 1 and args.kind_of? Range or args.length > 1
      @references[*args].map { |x| x.value }
    else
      @references[*args].value
    end
  end

  def []=(index, value)
    @references[index].value = value
  end

  def each
    @references.each do |x|
      yield x.value
    end
  end


  def add_ref( index )
    @references << ArrayIndexRef.new( @array, index )
  end
end


class Array
  def select_view
    r = ArrayView.new( self )
    each_with_index do |item, index|
      r.add_ref( index ) if yield( item )     end
    r
  end
end

a = (1..10).to_a

p a
b = a.select_view { |x| (x % 2).zero? }
b[0] = 42
p a

% ruby view.rb
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
[1, 42, 3, 4, 5, 6, 7, 8, 9, 10] 