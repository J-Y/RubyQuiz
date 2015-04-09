class RealityDistortionField
  OVERRIDE = [:+, :-, :*, :/, :>, :<, :>=, :<=, :==]
  CLASSES  = [Fixnum, Symbol, String]

  def self.on
    CLASSES.each do |klass|
      klass.class_eval do
        counter = 0
        OVERRIDE.each do |meth|
          # save old method:
          savemeth = "rdf_save_#{counter}".to_sym
          alias_method savemeth, meth if method_defined? meth
          counter = counter.next # since '+' is already overridden

          # override method to return an expression array:
          define_method meth do |other|
            [meth, self, other]
          end
        end
      end
    end
    # define new Object.method_missing()
    Object.class_eval do
      alias_method  :method_missing_orig, :method_missing
      define_method :method_missing do |meth, *args|
        [meth, *args]
      end
    end
  end

  # Clean up:
  def self.off
    CLASSES.each do |klass|
      klass.class_eval do
        counter = 0
        OVERRIDE.each do |meth|
          # restore original methods:
          savemeth = "rdf_save_#{counter}".to_sym
          if method_defined? savemeth
            alias_method meth, savemeth
          else
            remove_method meth
          end
          counter = counter.next
        end
      end
    end
    # restore original Object.method_missing()
    Object.class_eval do
      remove_method :method_missing
      alias_method  :method_missing, :method_missing_orig
    end
  end
end

class Object
  def sxp
    RealityDistortionField.on
    begin
      expression = yield
    ensure
      RealityDistortionField.off
    end
    expression
  end
end

require 'test/unit'

class SXPTest < Test::Unit::TestCase

  def test_quiz
    assert_equal [:max, [:count, :name]],   sxp{max(count(:name))}
    assert_equal [:count, [:+, 3, 7]],      sxp{count(3+7)}
    assert_equal [:+, 3, :symbol],          sxp{3+:symbol}
    assert_equal [:+, 3, [:count, :field]], sxp{3+count(:field)}
    assert_equal [:/, 7, :field],           sxp{7/:field}
    assert_equal [:>, :field, 5],           sxp{:field > 5}
    assert_equal 8,                         sxp{8}
    assert_equal [:==, :field1, :field2],   sxp{:field1 == :field2}
    assert_raises(TypeError)                {7/:field}
    assert_raises(NoMethodError)            {7+count(:field)}
    assert_equal 11,                        5+6
    assert_raises(NoMethodError)            {p(:field > 5)}
  end

  def test_more
    assert_equal [:+, "hello", :world], sxp{"hello" + :world}
    assert_equal [:count], sxp {count}
  end
end
