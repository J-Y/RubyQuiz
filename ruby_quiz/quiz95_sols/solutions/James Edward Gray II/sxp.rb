#!/usr/bin/env ruby -w

class SXP
  instance_methods.each do |meth|
    undef_method(meth) unless meth =~ /\A__/ or meth == "instance_eval"
  end
  
  def initialize(&block)
    @code = block
  end
  
  def method_missing(meth, *args, &block)
    if args.any? { |e| e.is_a? Array }
      [meth, args.inject(Array.new) { |arr, a| arr.push(*a) }]
    else
      [meth, *args]
    end
  end
  
  def result
    instance_eval(&@code)
  end
end

def sxp(&block)
  SXP.new(&block).result
end