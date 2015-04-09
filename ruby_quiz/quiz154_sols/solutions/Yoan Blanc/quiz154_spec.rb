#!/usr/bin/ruby

require 'quiz154'

describe "make_change" do
	it "should work with US money" do
		make_change(39).should == [25, 10, 1, 1, 1, 1]
	end
	
	it "should work with alien money" do
		make_change(14, [10, 7, 1]).should == [7, 7]
	end
	
	it "should work with non solvable solution" do
		make_change(0.5).should == nil
	end
	
	it "should now when not to give money back" do
		make_change(0).should == []
	end
	
	it "should agree with dh and Marcelo" do
		make_change(1000001, [1000000, 1]).should == [1000000, 1]
		make_change(10000001, [10000000, 1]).should == [10000000, 1]
		make_change(100000001, [100000000, 1]).should == [100000000, 1]
		
		make_change(1000001, [1000000, 2, 1]).should == [1000000, 1]
	end

	it "should not be naive (by James)" do
		make_change(24, [10, 8, 2]).should == [8, 8, 8]
		
		make_change(11, [10, 9, 2]).should == [9, 2]
	end

	it "should have a good pruning" do
		make_change(19, [5, 2, 1]).should == [5, 5, 5, 2, 2]
		make_change(39, [5, 2, 1]).should == [5, 5, 5, 5, 5, 5, 5, 2, 2]
	end
	
	it "should work with Swiss paper money" do
		money = [1000,500,200,100,50,20,10,5,2,1]
		make_change(1789, money).should == [1000,500,200,50,20,10,5,2,2]
	end
	
	it "should be nice to tho_mica_l" do
		money = [97, 89, 83, 79, 73, 71, 67, 61, 59, 53, 47, 43, 41, 37, 31, 29, 23, 19, 17, 13, 11, 7, 5, 3]
		make_change(101, money).should == [89, 7, 5]
		
		make_change(4563, money).should == [97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 89, 7, 5]
	end

	it "should fail with a combination trick (vsv)" do
		make_change(2**10-1, (1..10).map{|n| 2**n}).should == nil
		make_change(2**100-1, (1..100).map{|n| 2**n}).should == nil
	end
end