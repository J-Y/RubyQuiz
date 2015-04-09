#toothpick_spec.rb
require 'spec'
require 'toothpick'

context "Fixnum should convert itself to toothpick expression. Example..." do
	specify "1" do
		1.to_t.should == "|"
	end

	specify "2" do
		2.to_t.should == "||"
	end

	specify "7" do
		7.to_t.should == "|||||||"
	end

	specify "8" do
		8.to_t.should == "||x||||"
	end

	specify "9" do
		9.to_t.should == "|||x|||"
	end

	specify "12" do
		12.to_t.should == "|||x||||"
	end

	specify "27" do
		27.to_t.should == "|||x|||x|||"
	end
	
	specify "34" do
	  34.to_t.should == "||x||||x||||+||"
  end
	
	specify "100" do
	  100.to_t.should == "||||x|||||x|||||"
  end
	
	specify "138" do
	  138.to_t.should == "|||x||||||x|||||||+|||x||||"
  end
  
	specify "509" do
	  509.to_t.should == "||||||x|||||||x|||||||||||+|||x|||x|||||+||"
  end
  
  # This one runs really slow!!!!
  specify "verify results" do
    (1..300).each do |n|
      eval(n.toothpick_expression.to_s(true)).should == n
    end
  end
end

context "ToothpickExpression should say number of toothpicks for" do
  specify "1" do
    ToothpickExpression.find_short_expression(1).toothpick_count.should == 1
  end

  specify "11" do
    ToothpickExpression.find_short_expression(11).toothpick_count.should == 11
  end

  specify "12" do
    ToothpickExpression.find_short_expression(12).toothpick_count.should == 9
  end

  specify "34" do
    ToothpickExpression.find_short_expression(34).toothpick_count.should == 18
  end

  specify "100" do
    ToothpickExpression.find_short_expression(100).toothpick_count.should == 18
  end

  specify "509" do
    ToothpickExpression.find_short_expression(509).toothpick_count.should == 49
  end
end

context "ToothpickExpression should provide numeric expression for" do
	specify "1" do
	  ToothpickExpression.find_short_expression(1).to_s(true).should == "1"
  end
	specify "11" do
	  ToothpickExpression.find_short_expression(11).to_s(true).should == "11"
  end
	specify "12" do
	  ToothpickExpression.find_short_expression(12).to_s(true).should == "3*4"
  end
	specify "34" do
	  ToothpickExpression.find_short_expression(34).to_s(true).should == "2*4*4+2"
  end
	specify "100" do
	  ToothpickExpression.find_short_expression(100).to_s(true).should == "4*5*5"
  end
	specify "509" do
	  ToothpickExpression.find_short_expression(509).to_s(true).should == "6*7*11+3*3*5+2"
  end
end
