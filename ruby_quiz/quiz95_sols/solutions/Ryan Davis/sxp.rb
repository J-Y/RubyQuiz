#!/usr/local/bin/ruby -w

# Your mission: Create a function named sxp() that can take a block
# (not a string), and create an s-expression representing the code in
# the block.

require 'rubygems'
require 'parse_tree'
require 'sexp_processor'

############################################################
# From unreleased ruby2ruby:

class ProcStoreTmp
  @@n = 0
  def self.name
    @@n += 1
    return :"myproc#{@@n}"
  end
end

class Method
  def with_class_and_method_name
    if self.inspect =~ /<Method: (.*)\#(.*)>/ then
      klass = eval $1 # cheap
      method  = $2.intern
      raise "Couldn't determine class from #{self.inspect}" if klass.nil?
      return yield(klass, method)
    else
      raise "Can't parse signature: #{self.inspect}"
    end
  end

  def to_sexp
    with_class_and_method_name do |klass, method|
      ParseTree.new(false).parse_tree_for_method(klass, method)
    end
  end
end

class Proc
  def to_method
    name = ProcStoreTmp.name
    ProcStoreTmp.send(:define_method, name, self)
    ProcStoreTmp.new.method(name)
  end

  def to_sexp
    body = self.to_method.to_sexp[2][1..-1]
    [:proc, *body]
  end
end

# END unreleased ruby2ruby:
############################################################


class Quiz < SexpProcessor
  def initialize
    super
    self.auto_shift_type = true
    self.strict = false
    self.expected = Object
  end

  def process_proc(exp)
    return * _list(exp)
  end

  def process_fcall(exp)
    [exp.shift, process(exp.shift)]
  end

  def process_call(exp)
    lhs = process(exp.shift)
    name = exp.shift
    rhs = process(exp.shift)
    [name, lhs, rhs].compact
  end

  def process_array(exp)
    return * _list(exp)
  end

  def process_lit(exp)
    exp.shift
  end

  def process_str(exp)
    exp.shift
  end

  def _list(exp)
    result = []
    until exp.empty? do
      result << process(exp.shift)
    end
    result
  end
end

def sxp(&block)
  Quiz.new.process(block.to_sexp)
end

if $0 == __FILE__ then
  require 'test/unit'

  class TestQuiz < Test::Unit::TestCase
    def test_sxp_nested_calls
      assert_equal [:max, [:count, :name]], sxp{max(count(:name))}
    end

    def test_sxp_call_plus_eval
      assert_equal [:count, [:+, 3, 7]], sxp{count(3+7)}
    end

    def test_sxp_binarymsg_mixed_1
      assert_equal [:+, 3, :symbol], sxp{3+:symbol}
    end

    def test_sxp_binarymsg_mixed_call
      assert_equal [:+, 3, [:count, :field]], sxp{3+count(:field)}
    end

    def test_sxp_binarymsg_mixed_2
      assert_equal [:/, 7, :field], sxp{7/:field}
    end

    def test_sxp_binarymsg_mixed_3
      assert_equal [:>, :field, 5], sxp{:field > 5}
    end

    def test_sxp_lits
      assert_equal 8, sxp{8}
    end

    def test_sxp_binarymsg_syms
      assert_equal [:==, :field1, :field2], sxp{:field1 == :field2 }
    end

    def test_sxp_from_sander_dot_land_at_gmail_com
      assert_equal [:==,[:^, 2, 3], [:^, 1, 1]], sxp{ 2^3 == 1^1}
      assert_equal [:==, [:+, 3.0, 0.1415], 3], sxp{3.0 + 0.1415 == 3}

      assert_equal([:|,
                    [:==, [:+, :hello, :world], :helloworld],
                    [:==, [:+, [:+, "hello", " "], "world"], "hello world"]] ,
                   sxp {
                     (:hello + :world == :helloworld) |
                     ('hello' + ' ' + 'world' == 'hello world')
                   })

      assert_equal  [:==, [:+, [:abs, [:factorial, 3]], [:*, [:factorial, 4], 42]],
                     [:+, [:+, 4000000, [:**, 2, 32]], [:%, 2.7, 1.1]]],
      sxp{ 3.factorial.abs + 4.factorial * 42 ==  4_000_000 + 2**32 + 2.7 % 1.1 }
    end

    def test_ihavenocluewhy
      assert_equal 11, 5 + 6
      assert_raise(TypeError) { 7 / :field }
      assert_raise(NoMethodError) { 7+count(:field) }
      assert_raise(NoMethodError) { :field > 5 }
    end
  end
end
