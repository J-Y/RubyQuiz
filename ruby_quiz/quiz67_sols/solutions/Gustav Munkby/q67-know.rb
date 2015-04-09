#!/usr/bin/env ruby
#
# Ruby Quiz #67, metakoans.rb
# http://www.rubyquiz.com/quiz67.html
#
# You should write an implementation of a single method 'attribute'
# which behaves much like the built-in 'attr', but whose properties
# require delving deep into the depths of meta-ruby. usage of the
# 'attribute' method follows the general form of
#
#   class C
#     attribute 'a'
#   end
#
#   o = C::new
#   o.a = 42 # setter - sets @a
#   o.a # getter - gets @a
#   o.a? # query - true if @a
#
# The implementation should pass execution of the metakoans.rb script,
# without any problems, which should produce something like this:
#
#   dust:~ > ruby metakoans.rb q67-meta.rb
#   koan_1 has expanded your awareness
#   koan_2 has expanded your awareness
#   koan_3 has expanded your awareness
#   koan_4 has expanded your awareness
#   koan_5 has expanded your awareness
#   koan_6 has expanded your awareness
#   koan_7 has expanded your awareness
#   koan_8 has expanded your awareness
#   koan_9 has expanded your awareness
#   mountains are again merely mountains

class Object

  # Works much in the same way as isntance_variable_get, but with the
  # same features that the fetch method of Array and Hash, meaning
  # that an IndexError will be raised if a variable by the given name
  # doesn't exist.
  def instance_variable_fetch(name)
    r = instance_variable_get(name)
    raise IndexError unless r or instance_variables.include?(name)
    r
  end

end

class Module

  # Works much in the same way as attr_accessor, but allows you to
  # specify a default value, either by using a hash as in:
  #
  #   attribute :a => 42
  #
  # or by supplying a procedure:
  # 
  #   attribute :a { 42.to_s }
  # 
  # The method also provides an additional accessor function name?,
  # which might be more suiting in some contexts
  #
  def attribute(name, &block)
    if name.is_a?(Hash) and name.size == 1
      name, default_value = name.detect { true }
      block = proc { default_value }
    end
    module_eval do
      attr_accessor name
      if block
        define_method name do
          instance_variable_fetch("@#{name}") rescue instance_eval(&block)
        end
      end
      alias_method "#{name}?", name
    end
  end

end

if $0 == __FILE__
  exec './metakoans.rb', $0
end

