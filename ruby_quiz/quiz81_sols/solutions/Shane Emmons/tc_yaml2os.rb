#!/usr/local/bin/ruby -w

require 'test/unit'

require 'ostruct'

require 'yaml2os'

class TC_YAML2OS < Test::Unit::TestCase

  def setup
    @os = OpenStruct.new
    @os.foo          = 1
    @os.bar          = OpenStruct.new
    @os.bar.baz      = [ 1, 2, OpenStruct.new({'b' => 1, 'c' => 2}),
                         [3, 4, [5, OpenStruct.new({'d' => 3})]] ]
    @os.bar.quux     = 42
    @os.bar.doctors  = [ 'William Hartnell', 'Patrick Troughton',
                         'Jon Pertwee', 'Tom Baker', 'Peter Davison',
                         'Colin Baker', 'Sylvester McCoy', 'Paul McGann',
                         'Christopher Eccleston', 'David Tennant',
                         OpenStruct.new({'w' => 1, 't' => 7}) ]
    @os.bar.a        = OpenStruct.new({'x' => 1, 'y' => 2, 'z' => 3})
    @os.bar.b        = OpenStruct.new({'a' => [ 1,
                                                OpenStruct.new({'b' => 2}) ]})

    test_construction
  end

  def test_construction
    @yaml2os = YAML2OS.new('test.yaml')

    assert_not_nil(@yaml2os)
    assert_instance_of(YAML2OS, @yaml2os)
    assert_equal(@os, @yaml2os.os)

    @yaml2os = YAML2OS.new

    assert_not_nil(@yaml2os)
    assert_instance_of(YAML2OS, @yaml2os)
    assert_nil(@yaml2os.os)
  end

  def test_convert
    os = @yaml2os.convert('test.yaml')

    assert_equal(@os, os)
    assert_equal(@os, @yaml2os.os)
  end

end
