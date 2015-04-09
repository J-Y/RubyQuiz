#!/usr/bin/env ruby -wKU

require "test/unit"

require "rubygems"
require "mocha"

class TestMock < Test::Unit::TestCase
  def test_trying_a_mock
    str = "James"
    str.expects(:size)
    str.size
  end
end