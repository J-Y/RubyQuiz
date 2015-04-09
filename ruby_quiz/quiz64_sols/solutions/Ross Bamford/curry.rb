#
# Ruby Murray - Ruby version of Perl's Sub::Curry.
# (c)2006 Ross Bamford 
#
# For Ruby Quiz 64. License: Same as Ruby.
# See +Curry+ for documentation and +TestCurry+ for examples.
#
# You can download Ruby Murray (with documentation and explanatory
# comments) from http://roscopeco.co.uk/ruby-quiz-entries/64/curry.rb

require 'singleton'

# *Ruby* *Murray* is a Ruby port of Perl's Sub::Curry library that allows 
# curried blocks and methods to be handled in a pretty flexible way. 
#
# See http://search.cpan.org/~lodin/Sub-Curry-0.8/lib/Sub/Curry.pm and
# http://search.cpan.org/~lodin/Sub-Curry-0.8/lib/Sub/Curry/Cookbook.pod
# for details on the original, and some general background.
#
# Simple usage:
#
#   curry = lambda { |*args| args }.curry(Curry::HOLE, "foo", Curry::HOLE)
#   curry.call(1,3)     # => [1, "foo", 3]
#
#   curry = "string".method(:slice).curry(Curry::HOLE, 2)
#   curry.call(0)       # => "st"
#   curry.call(2)       # => "ri"
#
# The +curry+ methods are provided by the +Curriable+ module, which simply
# provides convenient wrapping for Curry.new. There are a few variations 
# between the various forms, but mostly they are equivalent and can be
# used interchangeably.
#
# See TestCurry (and click the method signatures) for more usage.
#
# Curried procs are immutable once created. If you wish to apply further
# special spice to a curried method, you may do so either using the 
# instance method +new+ to create a new curried proc by applying new
# spice to the old spice, or by passing the special spices directly to 
# a +call+.
#
# You can download Ruby Murray (with documentation and explanatory
# comments) from http://roscopeco.co.uk/ruby-quiz-entries/64/curry.rb
class Curry
  
  # A whitehole removes the blackhole, but the spice that has been put 
  # into the blackhole remains since blackholes themselves don't store 
  # anything.
  WHITEHOLE = Object.new

  # An antihole put in a hole makes the hole disappear. If the spice is
  # 1, <HOLE>, 3, <HOLE>, 4 and 2, <ANTIHOLE>, 5 is applied then the 
  # result will become 1, 2, 3, 4, 5.
  ANTIHOLE = Object.new

  def WHITEHOLE.inspect #:nodoc:
    "<WHITEHOLE>"
  end 
  def ANTIHOLE.inspect #:nodoc:
    "<ANTIHOLE>"
  end
  
  # Just a base class for 'active' special spices (holes, really). 
  # SpiceArgs have a spice_arg method that must return an array.
  # Maybe you can subclass up your own special spices...
  #
  # All the standard subclasses are singletons, the instance of
  # which is assigned to the appropriate constant (HOLE, BLACKHOLE,
  # etc).
  class SpiceArg
    def initialize(name)
      @name = name
    end

    def spice_arg(args_remain)
      raise NoMethodError, "Abstract method"
    end

    def inspect
      "<#{@name}>"
    end
  end

  class HoleArg < SpiceArg #:nodoc: all
    include Singleton
    def initialize; super("HOLE"); end
    def spice_arg(args_remain)
      a = args_remain.shift
      if a == ANTIHOLE
        []
      else
        [a]
      end
    end
  end
  
  class BlackHoleArg < SpiceArg #:nodoc: all
    include Singleton
    def initialize; super("BLACKHOLE"); end
    def spice_arg(args_remain)
      if idx = args_remain.index(WHITEHOLE)        
        args_remain.slice!(0..idx)[0..-2]
      else
        args_remain.slice!(0..args_remain.length)
      end
    end
  end

  class AntiSpiceArg < SpiceArg #:nodoc: all
    include Singleton
    def initialize; super("ANTISPICE"); end
    def spice_arg(args_remain)
      args_remain.shift
      []
    end
  end

  # A hole is what it sounds like: a gap in the argument list. Later, 
  # when the subroutine is called the holes are filled in. So if the
  # spice is 1, <HOLE>, 3 and then 2, 4 is applied to the curried proc,
  # the resulting argument list is 1, 2, 3, 4.
  #
  # Holes can be called "scalar inserters" that default to +nil+.
  HOLE = HoleArg.instance
  
  # A blackhole is like a hole for lists that never gets full. There's 
  # an imaginary untouchable blackhole at the end of the spice. The 
  # blackhole thusly inserts the new spice before itself. The blackhole 
  # never gets full because nothing is ever stored in a blackhole as it 
  # isn't a hole really...
  #
  # Blackholes are used to move the point of insertion from the end to
  # somewhere else, so you can curry the end of the argument list.
  #
  # Blackholes can be called "list inserters" that defaults to the
  # empty list.
  BLACKHOLE = BlackHoleArg.instance

  # An antispice is like a hole except that when it's filled it disappears.
  # It's like a combination of a hole and an antihole. If the spice is 
  # 1, <ANTISPICE>, 3 and 2, 4 is applied, then the result will become 
  # 1, 3, 4.
  ANTISPICE = AntiSpiceArg.instance
 
  # The raw spice held by this curried proc. May contain special
  # spices.
  attr_reader :spice

  # The block (+Proc+) for which arguments are curried.
  attr_reader :uncurried

  # call-seq:
  #   Curry.new(*spice) { |*args| ... }  -> #&lt;Curry...&gt;
  #   Curry.new(callable, *spice)        -> #&lt;Curry...&gt;
  #   
  # Create a new curry with the specified spice and
  # block or callable object. The second form requires only 
  # that the first argument respond_to?(:call)
  def initialize(*spice, &block)
    block = block || (spice.shift if spice.first.respond_to?(:call))
    raise ArgumentError, "No block supplied" unless block
    @spice, @uncurried = spice, block
  end

  # call-seq:
  #   some_curry.call(*args) { |b| ... } -> result
  #   some_curry[*args]      { |b| ... } -> result
  #   
  # Call the curried proc, passing the supplied arguments.
  # This method resolves all special spices and passes the
  # resolved arguments to the block. If a block is passed to
  # +call+ it will be passed on as a block argument to the curried
  # method *only* if this curry was created from a +Method+. Curries
  # created from a block passed to Curry.new (or from Proc#curry) 
  # cannot have block arguments passed to them.
  #
  # Unlike Perl's Sub::Curry implementation, special spices *may*
  # be passed in the call arguments, and are applied as with new.
  # This means that whiteholes and antiholes can be passed in to
  # make single-call modifications to the argument spice.
  # This probably isn't as great on performance but it's more fun.
  #
  # see also +new+
  def call(*args, &blk)
    @uncurried.call(*call_spice(args), &blk)
  end

  # Had some trouble with aliases and doc so it's done this way
  def [](*args) # :nodoc:
    call(*args)
  end

  # call-seq:
  #   some_curry.new(*spice) -> #&lt;Curry...&gt;
  #   
  # Create a new curried proc by applying the supplied spice to the
  # current spice in this curried proc. This does not simply append
  # the spices - Arguments in the supplied spice are applied to the
  # curried spice arguments, with black/white hole and antiholes
  # operating as documented. 
  #
  # See also +call+.  
  def new(*spice)
    Curry.new(*merge_spice(spice), &@uncurried)
  end

  # call-seq:
  #   some_curry.to_proc -> #&lt;Proc...&gt;
  #   
  # Convert to a proc
  def to_proc
    # since we're immutable we can keep this
    @extern_proc ||= method(:call).to_proc
  end 
  
  private 

  # Handles new curry merges
  def merge_spice(spice)
    largs = spice.dup
    
    res = @spice.inject([]) do |res, sparg|
      # If we've used all the new spice, don't
      # touch any more of the old spice.
      if sparg.is_a?(SpiceArg) && !largs.empty?
        res + sparg.spice_arg(largs)
      else
        res << sparg
      end
    end
   
    res + largs
  end

  # Merges, then resolves all special spices
  def call_spice(args)
    sp = merge_spice(args)
    sp.map do |a| 
      if a.is_a? SpiceArg
        nil
      else
        a
      end
    end
  end
end

# Provided for Perl compatibility
module Sub #:nodoc: all
  Curry = ::Curry
end

# Provides a +curry+ method that can be mixed in to classes that make
# sense with currying. Depends on +self+ implementing a +call+ method.
module Curriable
  # call-seq:
  #   curriable.curry(*spice) -> #&lt;Curry...&gt;
  #
  # Create a new curried proc from this curriable, using the supplied
  # spice.
  def curry(*spice)
    Curry.new(self, *spice)
  end
end

unless defined? NO_CORE_CURRY
  NO_CORE_CURRY = (ENV['NO_CORE_CURRY'] || $SAFE > 3)
end

unless NO_CORE_CURRY
  class Proc
    include Curriable
  end

  class Method
    include Curriable
  end
end

if $0 == __FILE__ || (TEST_CURRY if defined? TEST_CURRY)
  require 'test/unit'

  # Included for example purposes. Click method signatures to open code.
  class TestCurry < Test::Unit::TestCase
    def test_fixed_args
      curry = Curry.new(1,2,3) { |a,b,c| [a,b,c] }
      assert_equal [1,2,3], curry.call
    end

    def test_fixed_array_args
      curry = Curry.new([1],[2,3]) { |*args| args }
      assert_equal [[1],[2,3]], curry.call
    end

    def test_hole
      curry = Curry.new(1,Curry::HOLE,3) { |a,b,c| [a,b,c] }
      assert_equal [1,nil,3], curry.call
      assert_equal [1,2,3], curry.call(2)

      curry = Curry.new(1,Curry::HOLE,3,Curry::HOLE) { |*args| args }
      assert_equal [1,2,3,4], curry.call(2,4)

      # Make sure extra args go to the end
      assert_equal [1,2,3,4,5,6], curry.call(2,4,5,6)

      # Make sure array args are handled right.
      # This tests both explicitly holed arrays
      # and extra arrays at the end
      assert_equal [1,[2,'two'],3,[4,0],[[14]]], 
                   curry.call([2,'two'],[4,0],[[14]])
      
    end

    def test_antihole
      curry = Curry.new(1,Curry::HOLE,3) { |*args| args }
      assert_equal [1,3], curry.call(Curry::ANTIHOLE)

      curry = Curry.new(1,Curry::HOLE,3,Curry::HOLE,4) { |*args| args }
      assert_equal [1,2,3,4,5], curry.call(2,Curry::ANTIHOLE,5)
    end

    def test_antispice
      curry = Curry.new(1,Curry::ANTISPICE,3,Curry::HOLE,4) { |*args| args }
      assert_equal [1,3,4,5], curry.call(2,Curry::ANTIHOLE,5)
    end

    def test_black_hole
      # There's an implicit black-hole at the end
      # so this should just act as normal.
      curry = Curry.new(1,Curry::BLACKHOLE) { |*args| args }
      assert_equal [1,2,3], curry.call(2,3)

      curry = Curry.new(1,Curry::BLACKHOLE,3,4) { |*args| args }
      assert_equal [1,2,10,3,4], curry.call(2,10)
    end

    def test_white_hole
      #   spice gives 1
      #   blackhole gives 2
      #   blackhole finished by whitehole
      #   spice gives 3
      #   hole matches the 7
      #   spice gives 5
      #   remaining args give 8 and 9
      curry = Curry.new(1,Curry::BLACKHOLE,3,Curry::HOLE,5) { |*args| args }
      assert_equal [1,2,3,7,5,8,9], curry.call(2,Curry::WHITEHOLE,7,8,9)

      #   spice gives 1
      #   blackhole gives 10 and 20
      #   whitehole ends blackhole
      #   spice gives 3
      #   hole matches nothing, gives nil
      #   spice gives 5
      assert_equal [1,10,20,3,nil,5], curry.call(10,20,Curry::WHITEHOLE)

      #   spice gives 1
      #   blackhole gives 10, 20, 25
      #   whitehole kills black
      #   spice gives 3
      #   hole matches 4
      #   spice gives 5
      assert_equal [1,10,20,25,3,4,5], curry.call(10,20,25,Curry::WHITEHOLE,4)

      # Multiple blackholes.
      #
      #   spice gives 1
      #   blackhole 1 gives 10, 20, 25
      #   whitehole, blackhole 1 negated
      #   spice gives 6
      #   hole matches 40
      #   spice gives 3, 4
      #   blackhole 2 gives 50, 60
      #   spice gives 5
      curry = Curry.new(1,Curry::BLACKHOLE,6,Curry::HOLE,3,4,Curry::BLACKHOLE,5) { |*args| args }
      assert_equal [1,10,20,25,6,40,3,4,50,60,5], curry.call(10,20,25,Curry::WHITEHOLE,40,50,60)
    end

    def test_curry_from_curry
      curry = Curry.new(1,Curry::BLACKHOLE,6,Curry::HOLE,3,4,Curry::BLACKHOLE,5) { |*args| args }
      curry = curry.new(Curry::HOLE,Curry::WHITEHOLE,8,9,10)
      assert_equal [1,Curry::HOLE,6,8,3,4,9,10,5], curry.spice

      # How to add after that hole?
      curry = curry.new(Curry::HOLE, 4, Curry::BLACKHOLE)
      assert_equal [1,Curry::HOLE,6,8,3,4,9,10,5,4,Curry::BLACKHOLE], curry.spice

      curry = curry.new(Curry::ANTIHOLE)
      assert_equal [1,6,8,3,4,9,10,5,4,Curry::BLACKHOLE], curry.spice

      # how to add after that blackhole?
      curry = curry.new(3,Curry::BLACKHOLE,Curry::WHITEHOLE,0)
      assert_equal [1,6,8,3,4,9,10,5,4,3,Curry::BLACKHOLE,0], curry.spice

      assert_equal [1,6,8,3,4,9,10,5,4,3,2,1,0], curry.call(2,1)
    end

    def test_cant_block_to_curried_block
      a = Curry.new(1,2) { |*args| args }

      # block is lost
      assert_equal [1,2,3], a.call(3) { |b| }
    end

    def test_curry_proc
      a = [1,2,3,4,5]
      c = Curry.new(*a) { |*args| args * 2 }
      assert_equal [1,2,3,4,5,1,2,3,4,5], c.call

      if NO_CORE_CURRY
        warn "Skipping Proc extension test"
      else
        c = lambda { |*args| args * 2 }.curry(*a)
        assert_equal [1,2,3,4,5,1,2,3,4,5], c.call
      end
    end

    def test_curry_method
      a = [1,2,3,4,5]
      injsum = Curry.new(a.method(:inject),0)
      assert_equal 15, injsum.call { |s,i| s + i }

      if NO_CORE_CURRY
        warn "Skipping Method extension test"
      else
        injsum = a.method(:inject).curry(0)
        assert_equal 15, injsum.call { |s,i| s + i }
      end
    end

    def test_curry_to_proc
      curry = Curry.new(Curry::HOLE, Curry::HOLE, 'thou') { |ary,i,msg| ary << "#{i} #{msg}" }
      assert_equal ["1 thou", "2 thou", "3 thou"], [1,2,3].inject([],&curry) 
    end

    def test_alt_bits
      curry = Curry.new(Curry::BLACKHOLE, 'too', 'true') { |one, two, *rest| [one, two, rest] }
      assert_equal [1,2,['too','true']], curry[1,2]
    end

    def test_perlish
      s = "str"
      s = Sub::Curry.new(s.method(:+), "ing") 
      assert_equal "string", s.call
    end
  end

  if ARGV.member?('--doc') || !File.exist?('doc')
    ARGV.reject! { |a| a == '--doc' }
    system("rdoc #{__FILE__} #{'currybook.rdoc' if File.exists?('currybook.rdoc')} --main Curry")
  end
end  
  
