# Ruby Quiz #110:
# Address: http://www.rubyquiz.com/quiz110.html
#
# Author:  crafterm@gmail.com (http://crafterm.net/blog/)
#
# Notes:   This particular solution differs slightly from the original quiz in that it doesn't require the abbrev 
#          keyword, it searches all methods defined on the given object, rather than only 'abbrev' defined ones. 
#
#          The search algorithm looks for methods that start with the abbreviation string, and also for methods
#          whose name is made up of many strings combined with underscores, where the first letter of each string 
#          matches the abbreviation characters in order (ie. obj.almn matches obj.[a]_[l]ong_[m]ethod_[n]ame).
#
#          When $TESTING is false or undefined, the rubygem UI is reused to prompt the user for abbreviation matches
#          should the abbreviation match multiple method names.
#
#          Quiz tests have been converted into rspec style tests.

require 'rubygems'

class Object
  
  alias :orig_method_missing :method_missing

  def method_missing(sym, *args)
    matches = methods_starting_with(sym.to_s) + underscore_separated_methods(sym.to_s)
    case matches.length
    when 0: orig_method_missing(sym, *args)
    when 1: __send__(matches.pop, *args)
    else
      return matches if $TESTING
      ask(matches, sym, *args)
    end
  end

  private

  def ask(matches, sym, *args)
    method, idx = Gem::StreamUI.new($stdin, $stdout).choose_from_list("Multiple abbreviated matches, please choose a match or enter to ignore", matches << "ignore")
    if method.nil? or method == 'ignore'
      orig_method_missing(sym, *args)
    else
      __send__(method, *args)
    end
  end
  
  def methods_starting_with(abbrev)
    methods.select {|method| method =~ /^#{abbrev}/}
  end
  
  def underscore_separated_methods(abbrev)
    methods.select {|method| method =~ /#{create_underscored_matcher(abbrev)}/}
  end
  
  def create_underscored_matcher(abbrev)
    re = ""
    abbrev.length.times do |i|
      re << abbrev[i] << "[^_]*" if i == 0
      re << "_" << abbrev[i] << "[^_]*" if i > 0
    end
    re
  end

end


context "Given a method_missing implementation that routes method invocations based on abbreviated method names" do
  
  setup do
    $TESTING = true
    @a = Class.new {
      instance_methods.each do |m|
        undef_method m unless m =~ /^(_|define_method|methods|extend|method_missing|orig_method_missing)/ 
      end
			%w<next step stop soup>.each do | name |
				define_method name do nil end
			end
		}.new
  end
  
  specify "unambigious abbreviations should be routed automatically" do
    lambda {
      @a.ne
      @a.st
      @a.sou
      @a.stop
    }.should_not_raise NoMethodError
  end

  specify "abbreviations that do not match any methods should raise a NoMethodError" do
    lambda { @a.nee }.should_raise NoMethodError
  end
  
  specify "unmatched abbreviations should work following redefined methods" do
    x = @a.sto.should_be_nil
    def @a.sto
      42
    end
    @a.sto.should_be == 42
    @a.sou.should_be_nil
    @a.soup.should_be_nil
  end
  
  specify "unmatched abbreviations should work following mixed in modules" do
    mix = Module.new {
      def a; 42; end
    }
    
    lambda { @a.a }.should_raise NoMethodError
    @a.extend(mix)
    @a.a.should_be == 42
  end
  
  specify "unmatched abbreviations should work following singleton method definitions" do
    lambda { @a.aa }.should_raise NoMethodError
    
    class << @a
      def aa; 42; end
    end
    
    @a.aa.should_be == 42
  end
  
  specify "unambigious abbreviations that match underscore named method names should be routed automatically" do
    lambda { @a.almn }.should_raise NoMethodError
    def @a.a_long_method_name; 42; end
    @a.almn.should_be == 42
  end

end
