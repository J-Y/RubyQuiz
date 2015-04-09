class SxpGenerator

  def method_missing(meth, *args)
    [meth, *args]
  end

  BINARY_METHODS = [:+, :-, :*, :/, :%, :**, :^, :<, :>, :<=, :>=, :==]

  def self.overwrite_methods(mod)
    BINARY_METHODS.each do |method|
      mod.module_eval do
        if method_defined? method
          alias_method "__orig_#{method}__", method
        end
        define_method method do |arg|
          [method, self, arg]
        end
      end
    end
  end

  def self.restore_methods(mod)
    BINARY_METHODS.each do |method|
      mod.module_eval do
        orig_method = "__orig_#{method}__"
        if method_defined? orig_method
          alias_method method, orig_method
          remove_method orig_method
        else
          remove_method method
        end
      end
    end
  end

end


def sxp(&block)
  klasses = [Fixnum, Bignum, Symbol, Array, Float, String]
  klasses.each do |klass|
    SxpGenerator.overwrite_methods(klass)
  end
  begin
    result = SxpGenerator.new.instance_eval &block
  rescue Exception
    result = nil
  end
  klasses.each do |klass|
    SxpGenerator.restore_methods(klass)
  end
  result
end


require 'test/unit'

class TestSxp < Test::Unit::TestCase

  def test_function
    assert_equal [:max, [:count, :name]], sxp { max(count(:name)) }
  end

  def test_number
    assert_equal 8, sxp { 8 }
    assert_equal [:+, 3, 4], sxp { 3 + 4 }
    assert_equal [:+, 3, :symbol], sxp { 3 + :symbol }
    assert_equal [:/, 7, :field], sxp { 7 / :field }
  end

  def test_symbol
    assert_equal [:>, :field, 5], sxp { :field > 5 }
    assert_equal [:==, :field1, :field2], sxp { :field1 == :field2 }
  end

  def test_mixed
    assert_equal [:count, [:+, 3, 7]], sxp { count(3+7) }
    assert_equal [:+, 3, [:count, :field]], sxp { 3 + count(:field) }
  end

  def test_environment
    assert_equal [:-, 10, [:count, [:*, :field, 4]]],
                 sxp { 10 - count(:field * 4) }
    assert_raise(TypeError) { 7 / :field }
    assert_raise(NoMethodError) { 7 + count(:field) }
    assert_equal 11, 5 + 6
    assert_raise(NoMethodError) { :field > 5 }
  end

end
