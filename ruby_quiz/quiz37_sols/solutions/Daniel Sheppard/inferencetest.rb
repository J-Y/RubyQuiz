require 'test/unit'
require 'inference.rb'

class TestContradictionRules < Test::Unit::TestCase
	def setup
		@all1 = AllAreRule.new("x","y")
		@all2 = AllAreRule.new("y","x")
		@some1 = SomeAreRule.new("x","y")
		@some2 = SomeAreRule.new("y","x")
		@notall1 = NotAllAreRule.new("x","y")
		@notall2 = NotAllAreRule.new("y","x")
		@none1 = NoneAreRule.new("x","y")
		@none2 = NoneAreRule.new("y","x")
	end
	def testAllAre
		assert(@all1.contradicts?(@none1))
		assert(@all1.contradicts?(@none2))
		assert(@all1.contradicts?(@notall1))
		assert(!@all1.contradicts?(@notall2))
		assert(!@all1.contradicts?(@some1))
		assert(!@all1.contradicts?(@some2))
		assert(!@all1.contradicts?(@all1))
		assert(!@all1.contradicts?(@all2))
		assert(!@all1.contradicts?(NotAllAreRule.new("z","x")))
		assert(!@all1.contradicts?(NotAllAreRule.new("x","z")))
		assert(!@all1.contradicts?(NotAllAreRule.new("z","y")))
		assert(!@all1.contradicts?(NotAllAreRule.new("y","z")))
	end
	def testSomeAre
		assert(@some1.contradicts?(@none1))
		assert(@some1.contradicts?(@none2))
		assert(!@some1.contradicts?(@notall1))
		assert(!@some1.contradicts?(@notall2))
		assert(!@some1.contradicts?(@some1))
		assert(!@some1.contradicts?(@some2))
		assert(!@some1.contradicts?(@all1))
		assert(!@some1.contradicts?(@all2))
	end
	def testNotAllAre
		assert(!@notall1.contradicts?(@none1))
		assert(!@notall1.contradicts?(@none2))
		assert(!@notall1.contradicts?(@notall1))
		assert(!@notall1.contradicts?(@notall2))
		assert(!@notall1.contradicts?(@some1))
		assert(!@notall1.contradicts?(@some2))
		assert(@notall1.contradicts?(@all1))
		assert(!@notall1.contradicts?(@all2))
	end
	def testNoneAre
		assert(!@none1.contradicts?(@none1))
		assert(!@none1.contradicts?(@none2))
		assert(!@none1.contradicts?(@notall1))
		assert(!@none1.contradicts?(@notall2))
		assert(@none1.contradicts?(@some1))
		assert(@none1.contradicts?(@some2))
		assert(@none1.contradicts?(@all1))		
		assert(@none1.contradicts?(@all2))
	end	
	def testUniqueness
		array = [@all1,@all2,@some1,@some2,@notall1,@notall2,@none1,@none2]
		assert_equal(8, array.size)
		assert_equal(8, array.uniq.size)
		newRule = AllAreRule.new("x","y")
		assert(@all1 == newRule)
		assert(@all1 === newRule)
		assert_equal(@all1, newRule)
		assert(array.include?(newRule))
	end
	def testParsedRules
		/all (.*s) are (.*s)\.?/ === "All mammals are hairy animals."
		allRule = AllAreRule.new($1,$2);
		/no (.*s) are (.*s)\.?/ === "No mammals are hairy animals."
		noRule = NoneAreRule.new($1,$2)
		/some (.*s) are not (.*s)\.?/ === "Some mammals are not hairy animals."
		notAllRule = NotAllAreRule.new($1,$2)
		assert_equal(allRule.thing, noRule.thing)
		assert_equal(allRule.thing, notAllRule.thing)
		assert_equal(allRule.other_thing, noRule.other_thing)
		assert_equal(allRule.other_thing, notAllRule.other_thing)
		assert(allRule.contradicts?(noRule))
		assert(noRule.contradicts?(allRule))
		assert(notAllRule.contradicts?(allRule))
		assert(allRule.contradicts?(notAllRule))
	end
end

class TestInference < Test::Unit::TestCase
	def testNoKnowledge
		engine = Inference.new
		assert_equal("I don't know anything about those things.", engine.process("Are all goldfish mammals?"))
		assert_equal("I don't know anything about those things.", engine.process("Are all mammals goldfish?"))
		assert_equal("OK.", engine.process("All mammals are hairy animals."))
		assert_equal("I don't know anything about goldfish.", engine.process("Are all goldfish mammals?"))
		assert_equal("I don't know anything about goldfish.", engine.process("Are all mammals goldfish?"))
	end
	def testLinkAll
		engine = Inference.new
		assert_equal("OK.", engine.process("All mammals are hairy animals."))
		assert_equal("Yes, all mammals are hairy animals.", engine.process("Are all mammals hairy animals?"))
		assert_equal("Yes, some hairy animals are mammals.", engine.process("Are any hairy animals mammals?"))
	end
	def testInference
		engine = Inference.new
		assert_equal("OK.", engine.process("All mammals are hairy animals."))
		assert_equal("OK.", engine.process("All dogs are mammals."))
		assert_equal("Yes, all dogs are hairy animals.", engine.process("Are all dogs hairy animals?"))		
	end
	def testSomeIncludesAll
		engine = Inference.new
		assert_equal("OK.", engine.process("All mammals are hairy animals."))
		assert_equal("I know.", engine.process("Some mammals are hairy animals."))		
		assert_equal("I know.", engine.process("Some hairy animals are mammals."))		
	end
	def testBadKnowledge
		engine = Inference.new
		assert_equal("OK.", engine.process("All mammals are hairy animals."))
		assert_equal("Sorry, that contradicts what I already know.", engine.process("No mammals are hairy animals."))
		rule = NotAllAreRule.new("mammals", "hairy animals")
		assert(engine.rules.any? { |other| rule.contradicts?(other) })
		assert_equal("Sorry, that contradicts what I already know.", engine.process("Some mammals are not hairy animals."))
	end	
	def testSample
		engine = Inference.new
		assert_equal("OK.", engine.process("All mammals are hairy animals."))
		assert_equal("OK.", engine.process("All dogs are mammals."))
		assert_equal("OK.", engine.process("All beagles are dogs."))
		assert_equal("Yes, all beagles are hairy animals.", engine.process("Are all beagles hairy animals?"))
		assert_equal("OK.", engine.process("All cats are mammals."))
		assert_equal("I know.", engine.process("All cats are hairy animals."))
		assert_equal("I don't know.", engine.process("Are all cats dogs?"))
		assert_equal("OK.", engine.process("No cats are dogs."))
		assert_equal("No, no cats are dogs.", engine.process("Are all cats dogs?"))
		assert_equal("I know.", engine.process("All cats are hairy animals."))
		assert_equal("Yes, no cats are dogs.", engine.process("Are no cats dogs?"))
		assert_equal("Sorry, that contradicts what I already know.", engine.process("All mammals are dogs."))
		assert_equal("OK.", engine.process("Some mammals are brown animals."))
		assert_equal("Yes, some mammals are dogs.", engine.process("Are any mammals dogs?"))
		assert_equal("I don't know.", engine.process("Are any dogs brown animals?"))
		assert_equal("OK.", engine.process("Some dogs are brown animals."))
		assert_equal("OK.", engine.process("All brown animals are brown things."))
		assert_equal("Yes, some dogs are brown things.", engine.process("Are any dogs brown things?"))
		assert_equal([
			"All dogs are hairy animals.",
			"All dogs are mammals.",
			"No dogs are cats.",
			"Some dogs are beagles.",
			"Some dogs are brown animals.",
			"Some dogs are brown things.",	
		], engine.process("Describe dogs."))
		assert_equal("I don't know anything about goldfish.", engine.process("Are all goldfish mammals?"))
	end
	def testNegativeInference
		engine = Inference.new
		assert_equal("OK.", engine.process("All dogs are mammals."))
		assert_equal("OK.", engine.process("No octopuses are mammals."))
		#puts engine.rules
		#engine.rules.each {|x| p x }
		assert_equal("No, no octopuses are dogs.", engine.process("Are any octopuses dogs?"))
	end
	def testExtrapolation
		engine = Inference.new
		assert_equal("OK.", engine.process("All dogs are mammals."))
		assert_equal("OK.", engine.process("No octopuses are mammals."))
		assert(engine.rule_known?(SomeAreRule.new("dogs", "mammals")))
		assert(engine.rule_known?(SomeAreRule.new("mammals", "dogs")))
	end
	def testParseUnknownThingInput
		engine = Inference.new
		assert_equal("I don't know anything about those things.", engine.process("Are all big hairy goldfish monsters?"))
	end
	def testParsePartiallyKnownThingInput
		engine = Inference.new
		assert_equal("OK.", engine.process("All monsters are big things"));
		assert_equal("I don't know anything about those things.", engine.process("Are all big hairy goldfish monsters?"))
	end
	def testParsePartiallyKnownThingInput
		engine = Inference.new
		assert_equal("OK.", engine.process("All monsters are big things"));
		assert_equal("I don't know anything about big hairy goldfish.", engine.process("Are all big hairy goldfish monsters?"))
	end	
	def testParsePartiallyKnownThingInput2
		engine = Inference.new
		assert_equal("OK.", engine.process("All big hairy goldfish are big things"));
		assert_equal("I don't know anything about monsters.", engine.process("Are all big hairy goldfish monsters?"))
	end	
	def testPauloCapriotti1
		engine = Inference.new
		assert_equal("OK.", engine.process("All dogs are mammals"));
		assert_equal("OK.", engine.process("All mammals are animals"));
		assert_equal("OK.", engine.process("Some animals are not mammals"));
	end
end