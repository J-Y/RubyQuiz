# = lazylist.rb - Implementation of lazy lists for Ruby
#
# == Description
#
# This class implements lazy lists (or streams) for Ruby. Such lists avoid the
# computation of values which aren't needed for some computation. So it's
# possible to define infinite lists with a limited amount of memory. A value
# that hasn't been used yet is calculated on the fly and saved into the list.
# A value which is used for a second time is computed only once and just read
# out of memory for the second usage.
#
# == Author
#
# Florian Frank mailto:flori@ping.de
#
# == License
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License Version 2 as published by the Free
# Software Foundation: www.gnu.org/copyleft/gpl.html
#
# == Download
#
# The latest version of this library can be downloaded at
#
# * http://rubyforge.org/frs?group_id=394
#
# The homepage of this library is located at
#
# * http://lazylist.rubyforge.org
# 
# == Example
#
# To compute the square numbers with a lazy list you can define one as
#
#  sq = LazyList.tabulate(1) { |x| x * x }
#
# Now it's possible to get the first 10 square numbers by calling
# LazyList#take
#
#  sq.take(10)
#      ==>[1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
#
# To compute the first 10 square numbers and do something with them you can
# call the each method with:
#
#  sq.each(10) { |x| puts x }
#
# To compute every square number and do something with them you can call the
# "each" method without an argument:
#
#  sq.each { |x| puts x }
#
# Notice that calls to each without an argument will not return if applied to
# infinite lazy lists.
#
# You can also use indices on lazy lists to get the values at a certain range:
#
#  sq[ 0..9 ] or sq[0, 10]
#      ==>[1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
# 
# To spare memory it's possible to throw away every element after it was
# fetched:
#
#  sq.take!(1) => [1]
#  sq.take!(1) => [4]
#
# Of course it's also possible to compute more complex lists like the Fibonacci
# sequence:
#
#  fib = LazyList.tabulate(0) { |x| x < 2 ? 1 : fib[x-2] + fib[x-1] }
#
#  fib[100] => 573147844013817084101
# computes the 99th Fibonacci number. (We always start with index 0.)
#  fib[101] => 927372692193078999176
# computes the 100th Fibonacci number. The already computed values are reused
# to compute this result. That's a very transparent way to get memoization for
# sequences that require heavy computation.
# 
# You can create lazy lists that are based on arbitrary Enumerables, so can for
# example wrap your passwd file in one pretty easily:
#
#  pw = LazyList[ File.new("/etc/passwd") ]
# 
# Call grep to find the users root and flori:
# pw.grep /^(root|flori):/ => ["root:x:0:0:...\n",... ]
#
# In this case the whole passwd file is slurped into the memory. If
# you use 
#  pw.find { |x| x =~ /^root:/ } => "root:x:0:0:root:/root:/bin/bash\n"
# instead, only every line until the root line is loaded into the memory.
#
# == References
#
# A very good introduction into lazy lists can be found in the scheme bible
# Structure and Interpretation of Computer Programs (SICP)
# [http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-24.html#%25_sec_3.5]
# 
class LazyList
  module Enumerable
    include ::Enumerable

    # Returns two lazy lists, the first containing the elements of this lazy
    # list for which the block evaluates to true, the second containing the
    # rest.
    def partition(&block)
      return select(&block), reject(&block)
    end


    # Returns a sorted version of this lazy list. This method should only be
    # called on finite lazy lists or it will never return. Also see
    # Enumerable#sort.
    def sort # :yields: a, b
      LazyList.from_enum(super)
    end

    # Returns a sorted version of this lazy list. This method should only be
    # called on finite lazy lists or it will never return. Also see
    # Enumerable#sort_by.
    def sort_by # :yields: obj
      LazyList.from_enum(super)
    end

    # Calls _block_ with two arguments, the element and its index, for each
    # element of this lazy list. If _block_ isn't given, the method returns a
    # lazy list that consists of [ element, index ] pairs instead.
    def each_with_index(&block)
      if block
        each_with_index.each { |x| block.call(x) }
      else
        i = -1
        map { |x| [ x, i += 1 ] }
      end
    end

    # Returns the lazy list, that contains all the given _block_'s return
    # values, if it was called on every
    #  self[i], others[0][i], others[1][i],... others[others.size - 1][i]
    # for i in 0..Infinity. If _block_ wasn't given
    # this result will be the array
    #  [self[i], others[0][i], others[1][i],... ]
    # and a lazy list of those arrays is returned.
    def zip(*others, &block)
      if empty? or others.any? { |o| o.empty? }
        Empty
      else
        block ||= lambda { |*all| all }
        list(block.call(head, *others.map { |o| o.head })) do
          tail.zip(*others.map { |o| o.tail}, &block)
        end
      end
    end

    # obsoleted by #zip
    def combine(other, &operator)
      warn "method 'combine' is obsolete - use 'zip'"
      zip(other, &operator)
    end

    # Returns a lazy list every element of this lazy list for which
    # pattern ===  element is true. If the optional _block_ is supplied,
    # each matching element is passed to it, and the block's result becomes
    # an element of the returned lazy list.
    def grep(pattern, &block)
      result = select { |x| pattern === x }
      block and result = result.map(&block)
      result
    end

    # Returns a lazy list of all elements of this lazy list for which the block
    # is false (see also +Lazylist#select+).
    def reject
      select { |obj| !yield(obj) }
    end

    # Returns a lazy list of all elements of this lazy list for which _block_
    # is true.
    def select(&block)
      block = Identity unless block
      s = self
      until s.empty? or block[s.head] do
        s = s.tail
      end
      return Empty if s.empty?
      self.class.new(s.head) { s.tail.select(&block) }
    end
    alias find_all select

    # obsoleted by #select
    def filter(&p)
      warn "method 'filter' is obsolete - use 'select'"
      select(&p)
    end

    # Creates a new Lazylist that maps the block or Proc object f to every
    # element in the old list.
    def map(&f)
      return Empty if empty?
      f = Identity unless f
      self.class.new(f[head]) { tail.map(&f) }
    end
    alias collect map

    # obsoleted by #map
    def mapper(&f)
      warn "method 'mapper' is obsolete - use 'map'"
      map(&f)
    end
  end
  include LazyList::Enumerable

  # Exceptions raised by the LazyList implementation.
  class Exception < ::Exception; end

  # ReadQueue is the implementation of an read-only queue that only supports
  # #pop and #empty? methods.  It's used as a wrapper to encapsulate
  # enumerables in lazy lists.
  class ReadQueue
    # Creates an ReadQueue object from an enumerable.
    def initialize(enumerable)
      @enumerable = enumerable
      @break = proc {}
      @enumerable.each do |x|
        @current = x
        callcc do |@continue|
          @break.call
          return
        end
      end
      @continue = false
      @break.call
    end

    # Extracts the top element from the queue or nil if the queue is
    # empty.
    def pop
      top = @current
      callcc { |@break| @continue.call } unless empty?
      top
    end

    # Returns true if the queue is empty.
    def empty?
      @continue == false
    end
  end

  # Returns a new lazy list, unless head and tail are nil. In the latter case
  # LazyList::Empty is returned.
  def self.new(head, tail = nil, &promise)
    if head.nil? and tail.nil?
      if LazyList.const_defined?(:Empty)
        Empty
      else
        super
      end
    else
      super
    end
  end

  # Creates a new LazyList element. The tail can be given either as
  # second argument or as block.
  def initialize(head, tail = nil, &promise)
    @cached = true
    @ref_cache = {}
    if tail
      promise and
        raise LazyList::Exception,
          "Use block xor second argument for constructor"
      @head, @tail = head, tail
    elsif promise
      @head, @tail = head, promise
    end
  end

  # Set this to false, if index references into the lazy list shouldn't be
  # cached for fast access (while spending some memory on this). This value
  # defaults to true.
  attr_writer :cached

  # Returns true, if index references into the lazy list are cached for fast
  # access to the referenceѕ elements.
  def cached?
    !!@cached
  end

  # Denotes the empty LazyList which is a guard at the end of finite
  # lazy lists.
  Empty = new(nil, nil)

  # Returns the value of this element.
  attr_accessor :head
  protected :head=

  # Writes a tail value.
  attr_writer :tail
  protected :tail=

  # Returns the next element by computing its value if necessary.
  def tail
    if @tail.is_a? Proc
      @tail = @tail[@head] || Empty
    end
    @tail
  end

  # Returns the tail of this list without evaluating.
  def peek_tail
    @tail
  end
  protected :peek_tail

  # Identity lambda expression, mostly used as a default.
  Identity = lambda { |x| x }

  # Returns a lazy list which is generated from the Enumerable a or
  # LazyList.span(a, n), if n was given as an argument.
  def self.[](a, n = nil)
    case
    when n
      span(a, n)
    when IO === a
      io(a)
    else
      from_enum(a)
    end
  end

  # Generates a lazy list from any data structure e which
  # responds to the #each method. 
  def self.from_enum(e)
    oq = ReadQueue.new(e)
    return Empty if oq.empty?
    next_top = proc do
      if oq.empty?
        Empty
      else
        new(oq.pop, next_top)
      end
    end
    new(oq.pop, next_top)
  end

  # Generates a finite lazy list beginning with element a and spanning
  # n elements. The data structure members have to support the
  # successor method succ.
  def self.span(a, n)
    if n > 0
      new(a) { span(a.succ, n - 1) }
    else
      Empty
    end
  end

  # Generates a lazy list which tabulates every element beginning with n
  # and succeding with succ by calling the Proc object f or the given block.
  # If none is given the identity function is computed instead.
  def self.tabulate(n = 0, &f)
    f = Identity unless f
    new(f[n]) { tabulate(n.succ, &f) }
  end

  # Returns a list of all elements succeeding _n_ and starting from _n_.
  def self.from(n = 0)
    tabulate(n)
  end
  
  # Generates a lazy list which iterates over its previous values
  # computing something like: f(i), f(f(i)), f(f(f(i))), ...
  def self.iterate(i = 0, &f)
    new(i) { iterate(f[i], &f) }
  end

  # Generates a lazy list of a give IO-object using a given
  # block or Proc object to read from this object.
  def self.io(input, &f)
    if f
      input.eof? ? Empty : new(f[input]) { io(input, &f) }
    else
      input.eof? ? Empty : new(input.readline) { io(input) }
    end
  end

  # Returns the sublist, constructed from the Range _range_ indexed elements,
  # of this lazy list.
  def sublist_range(range)
    f = range.first
    l = range.exclude_end? ? range.last - 1 : range.last
    sublist_span(f, l - f + 1)
  end

  # Returns the sublist, that spans _m_ elements starting from the _n_-th
  # element of this lazy list, if _m_ was given. If _m_ is non­positive, the
  # empty lazy list LazyList::Empty is returned.
  #
  # If _m_ wasn't given returns the _n_ long sublist starting from the first
  # (index = 0) element. If _n_ is non­positive, the empty lazy list
  # LazyList::Empty is returned.
  def sublist_span(n, m = nil)
    if not m
      sublist_span(0, n)
    elsif m > 0
      l = ref(n)
      self.class.new(l.head) { l.tail.sublist_span(0, m - 1) }
    else
      Empty
    end
  end

  # Returns the result of sublist_range(n), if _n_ is a Range. The result of
  # sublist_span(n, m), if otherwise.
  def sublist(n, m = nil)
    if n.is_a? Range
      sublist_range(n)
    else
      sublist_span(n, m)
    end
  end

  def set_ref(n, value)
    return value unless cached?
    @ref_cache[n] = value
  end
  private :set_ref

  # Returns the n-th LazyList-Object.
  def ref(n)
    if @ref_cache.key?(n)
      return @ref_cache[n]
    end
    s = self
    i = n
    while i > 0 do
      if s.empty?
        return set_ref(n, self)
      end
      s = s.tail
      i -= 1
    end
    set_ref(n, s)
  end
  private :ref

  # If n is a Range every element in this range is returned.
  # If n isn't a Range object the element at index n is returned.
  # If m is given the next m elements beginning the n-th element are
  # returned.
  def [](n, m = nil)
    if n.is_a? Range
      sublist(n)
    elsif n < 0
      nil
    elsif m
      sublist(n, m)
    else
      ref(n).head
    end
  end

  # Iterates over all elements. If n is given only n iterations are done.
  # If self is a finite lazy list each returns also if there are no more
  # elements to iterate over.
  def each(n = nil)
    s = self
    while (n.nil? or n > 0) and not s.empty? do
      yield s.head
      s = s.tail
      n -= 1 unless n.nil?
    end
    s
  end

  # Similar to LazyList#each but destroys elements from past
  # iterations perhaps saving some memory.
  def each!(n = nil)
    s = self
    while (n.nil? or n > 0) and not s.empty? do
      yield s.head
      s = s.tail
      n -= 1 unless n.nil?
      @head, @tail = s.head, s.tail
    end
    self
  end

  # Merges this lazy list with the other. It uses the &compare block to decide
  # which elements to place first in the result lazy list. If no compare block
  # is given lambda { |a,b| a < b } is used as a default value.
  def merge(other, &compare)
    compare = lambda { |a, b| a < b } unless compare
    return other if empty?
    return self if other.empty?
    if compare[head, other.head]
      self.class.new(head) { tail.merge(other, &compare) }
    elsif compare[other.head, head]
      self.class.new(other.head) { merge(other.tail, &compare) }
    else
      self.class.new(head) { tail.merge(other.tail, &compare) }
    end
  end

  # Append this lazy list to the _*other_ lists, creating a new lists that
  # consists of the elements of this list and the elements of the lists other1,
  # other2, ... If any of the lists is infinite, the elements of the following
  # lists will never occur in the result list.
  def append(*other)
    if empty?
      if other.empty?
        Empty
      else
        other.first.append(*other[1..-1])
      end
    else
      list(head) { tail.append(*other) }
    end
  end

  alias + append

  # Takes the next n elements and returns them as an array.
  def take(n = 1)
    result = []
    each(n) { |x| result << x }
    result
  end

  # Takes the _range_ indexes of elements from this lazylist and returns them
  # as an array.
  def take_range(range) 
    range.map { |i| ref(i).head }
  end

  # Takes the m elements starting at index n of this lazy list and returns them
  # as an array.
  def take_span(n, m)
    s = ref(n)
    s ? s.take(m) : nil
  end

  # Takes the next n elements and returns them as an array. It destroys these
  # elements in this lazy list. Also see #each! .
  def take!(n = 1)
    result = []
    each!(n) { |x| result << x }
    result
  end

  # Drops the next n elements and returns the rest of this lazy list. n
  # defaults to 1.
  def drop(n = 1)
    each(n) { }
  end

  # Drops the next n elements, destroys them in the lazy list and
  # returns the rest of this lazy list. Also see #each! .
  def drop!(n = 1)
    each!(n) { }
  end

  # Returns the size. This is only sensible if the lazy list is finite
  # of course.
  def size
    inject(0) { |s,| s += 1 }
  end

  alias length size

  # Returns true if this is the empty lazy list.
  def empty?
    self.equal? Empty
  end

  # Returns true, if this lazy list and the other lazy list consist of only
  # equal elements. This is only sensible, if the lazy lists are finite and you
  # can spare the memory.
  def eql?(other)
    other.is_a? self.class or return false
    size == other.size or return false
    to_a.zip(other.to_a) { |x, y| x == y or return false }
    true
  end
  alias == eql?

  # Inspects the list as far as it has been computed by returning
  # a string of the form [1, 2, 3,... ].
  def inspect
    result = "["
    s = self
    until s.empty?
      pt = s.peek_tail
      case 
      when pt.equal?(Empty) # to avoid calling == on pt
        result << s.head.inspect
        break
      when Proc === pt
        result << s.head.inspect << ",... "
        break
      else
        t = s.tail
        if t.equal? self
          result << s.head.inspect << ",... "
          break
        else
          result << s.head.inspect << ", "
          s = t
        end
      end
    end
    result << "]"
  end

  alias to_s inspect
end

module Kernel
  # A method to improve the user friendliness for creating new lazy lists, that
  # cannot be described well with LazyList#iterate or LazyList#tabulate.
  #
  # - list without any arguments, returns the empty lazy list LazyList::Empty.
  # - list(x) returns the lazy list with only the element x as a member,
  #   list(x,y) returns the lazy list with only the elements x and y as a
  #   members, and so on.
  # - list(x) { xs } returns the lazy list with the element x as a head
  #   element, and that is continued with the lazy list xs as tail. To define an
  #   infinite lazy list of 1s you can do:
  #    ones = list(1) { ones } # => [1,... ]
  #   To define all even numbers directly, you can do:
  #    def even(n = 0) list(n) { even(n + 2) } end
  #   and then:
  #    e = even # => [0,... ]
  def list(*values, &promise)
    result = LazyList::Empty
    last = nil
    values.reverse_each do |v|
      result = LazyList.new(v, result)
      last ||= result
    end
    if last and block_given?
      last.instance_variable_set :@tail, promise
    end
    result
  end
end
  # vim: set et sw=2 ts=2:
