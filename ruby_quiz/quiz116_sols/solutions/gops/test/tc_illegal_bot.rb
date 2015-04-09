#!/usr/bin/env ruby -w

require "test/unit"

class TestIllegalBot < Test::Unit::TestCase
  def setup
    bot_file = File.join(File.dirname(__FILE__), *%w[.. bot illegal.rb])
    @bot     = IO.popen("ruby #{bot_file} 2>&1", "r+")
  end
  
  def test_makes_illegal_plays
    @bot.puts "Bid card:  13"
    assert(!(2..14).include?(@bot.gets.strip.to_i), "Bot made a legal play.")
  end
end