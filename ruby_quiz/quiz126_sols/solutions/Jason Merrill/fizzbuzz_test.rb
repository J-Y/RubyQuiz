require 'spec'
require 'fizzbuzz'

describe :fizzbuzz do
 # This is just so we can read the results of all those 'puts'
 before do
   @output = StringIO.new()
   $stdout = @output
   fizzbuzz()
   @output.rewind
   @lines = @output.readlines.map {|str| str.chomp}
 end

 after do
   $stdout = STDOUT
 end

 it "should print 1 as the first line" do
   @lines[0].to_i.should == 1
 end

 it "should print 100 lines" do
   @lines.size.should == 100
 end

 it "should print 'Fizz' as the third line" do
   @lines[2].should == 'Fizz'
 end

 it "should print 'Buzz' as the fifth line" do
   @lines[4].should == 'Buzz'
 end

 it "should print 'FizzBuzz' as the fifteenth line" do
   @lines[14].should == 'FizzBuzz'
 end

 it "should print 'Buzz' as the last line" do
   @lines.last.should == 'Buzz'
 end

end
