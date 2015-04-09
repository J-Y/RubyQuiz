
# Fixed Width Integer Class for Ruby Quiz #85
# (C) 2006 Jürgen Strobel <juergen@strobel.info>
#
# This program is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any
# later version.

require "forwardable.rb"

# Base class for Integer classes with a fixed bit width
#
# Almost all methods are delegated to an encapsulated integer object.
# Metaprogramming is used to automate delegation & conversion.
#
class FixedWidthInt 

  include Comparable
  extend Forwardable
  private_class_method :new

  def self.def_fwi_delegator(accessor, method)  # taken from forward.rb
    module_eval(<<-EOS, "(__FWI_DELEGATION__)", 1)
      def #{method}(*args, &block)
        begin
          #puts "delegating #{method} and converting the result"
          self.class.new(#{accessor}.__send__(:#{method}, *args, &block), width)
        rescue Exception
          $@.delete_if{|s| /^\\(__FWI_DELEGATION__\\):/ =~ s} unless Forwardable::debug
          Kernel::raise
        end
      end
    EOS
  end
  def method_missing(op, *args)                 # a method is missing?
    if @i.respond_to?(op)                       # our @i could handle it?
      #puts "defining new method #{op}"
      FixedWidthInt.def_fwi_delegator :@i, op   #   define it by delegation!
      self.send(op, *args)                      #   and try again
    else                                        # else
      super                                     #   NoMethodError
    end
  end

  def initialize(i = 0, w = 8)
    w = w.to_i
    raise "Invalid width" unless w >= 1
    @width, @i = w, i.to_i & ((1<<w) - 1)
  end

  def coerce_to_width(nw)
    self.class.new(i, nw)
  end

  def inspect
    "#{self.i}(#{self.class.name[0,1]}#{width})"
  end

  attr_reader :i, :width
  def_delegators :@i, :[], :zero?
  def_delegators :i, :to_i, :to_s, :<=>, :times, :coerce, :divmod, :quo, :to_f

  # We might have to define or delegate more methods explicitly which
  # are not working correctly with #method_missing. Especially those
  # not returning a FixedWidthInt.
end

# A fixed width unsigned integer
class UnsignedFixedWidthInt < FixedWidthInt
  public_class_method :new
end

# A fixed width signed integer
class SignedFixedWidthInt < FixedWidthInt
  public_class_method :new

  # Interpret @i differently if the highest bit is set, everything
  # else works magically thanks to 2's complement arithmentic.
  def i
    if (@i >> (width-1)).zero?
      @i
    else
      @i - (1 << width)
    end
  end
end 
