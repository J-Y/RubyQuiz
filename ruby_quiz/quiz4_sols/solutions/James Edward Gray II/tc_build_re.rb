#!/usr/bin/env ruby

require "test/unit"

class TestRegexpBuild < Test::Unit::TestCase
	def test_integers
		lucky = /^#{Regexp.build(3, 7)}$/
		assert_match(lucky, "7")
		assert_no_match(lucky, "13")
		assert_match(lucky, "3")

		month = /^#{Regexp.build(1..12)}$/
		assert_no_match(month, "0")
		assert_match(month, "1")
		assert_match(month, "12")
		day = /^#{Regexp.build(1..31)}$/
		assert_match(day, "6")
		assert_match(day, "16")
		assert_no_match(day, "Tues")
		year = /^#{Regexp.build(98, 99, 2000..20005)}$/
		assert_no_match(year, "04")
		assert_match(year, "2004")
		assert_match(year, "99")
		
		num = /^#{Regexp.build(1..1_000)}$/
		assert_no_match(num, "-1")
		(-10_000..10_000).each do |i|
			if i < 1 or i > 1_000
				assert_no_match(num, i.to_s)
			else
				assert_match(num, i.to_s)
			end
		end
	end

	def test_embed
		month = Regexp.build("01".."09", 1..12)
		day = Regexp.build("01".."09", 1..31)
		year = Regexp.build(95..99, "00".."05")
		date = /\b#{month}\/#{day}\/(?:19|20)?#{year}\b/
		
		assert_match(date, "6/16/2000")
		assert_match(date, "12/3/04")
		assert_match(date, "Today is 09/15/2004")
		assert_no_match(date, "Fri Oct 15")
		assert_no_match(date, "13/3/04")
		assert_no_match(date, "There's no date hiding in here:  00/00/00!")
		
		md = /^(#{Regexp.build(1..12)})$/.match("11")
		assert_not_nil(md)
		assert_equal(md[1], "11")
	end

	def test_words
		animal = /^#{Regexp.build("cat", "bat", "rat", "dog")}$/
		assert_match(animal, "cat")
		assert_match(animal, "dog")
		assert_no_match(animal, "Wombat")
	end
end
