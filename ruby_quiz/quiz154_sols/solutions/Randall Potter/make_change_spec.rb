
require 'make_change'

describe 'CoinChanger' do
  
  it 'should handle 0' do
    CoinChanger.make_change(0).should == []
  end
  
  it 'should have default coins = [25, 10, 5, 1]' do
    CoinChanger.make_change(41).should == [25, 10, 5, 1]
  end
  
  it 'should return single coins' do
    CoinChanger.make_change(10, [10, 7, 1]).should == [10]
  end
  
  it 'should return single middle coins' do
    CoinChanger.make_change(7, [10, 7, 1]).should == [7]
  end
  
  it 'should minimize pennies' do
    CoinChanger.make_change(21, [10, 7, 1]).should == [7,7,7]
  end
  
  it 'should handle coin values in any order' do
    CoinChanger.make_change(21, [10, 7, 1]).should == CoinChanger.make_change(21, [7, 1, 10])
  end
  
  it 'should treat middle values as first class citizens' do
    CoinChanger.make_change(14, [10, 7, 1]).should == [7,7]
  end
  
  it 'should avoid being naive :)' do
    CoinChanger.make_change(24,[10,8,2]).should == [8,8,8]
  end
  
  it 'should err in favor of giving back more' do
    # the Australian example
    CoinChanger.make_change(799, [200, 100, 50, 20, 10, 5]).should == [200, 200, 200, 200]
  end
  
  it 'should handle non zero values less than the smallest coin' do
    CoinChanger.make_change(3, [10, 5]).should == [5]
  end
  
  it 'should sanely handle coins that close in value to their parent' do
    CoinChanger.make_change(397, [100, 99, 1]).should == [100,99,99,99]
  end
  
  it 'should have higher coins first' do
    c = CoinChanger.make_change(497, [100, 99, 1])
    c.should == c.sort.reverse
  end
  
  #  it 'should be fast' do
    #  make_change(1000001, [1000000, 1])
  #  end
  
  it 'should prefer more accurate over lighter answers' do
    c = CoinChanger.make_change(4563, [97, 89, 83, 79, 73, 71, 67, 61, 59, 53, 47, 43, 41, 37, 31, 29, 23, 19, 17, 13, 11, 7, 5, 3])
    c.size.should <= 49
    c.weight.should == 4563
  end
  
end