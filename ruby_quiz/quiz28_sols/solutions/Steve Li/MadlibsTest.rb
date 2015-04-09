require 'runit/testcase'
require 'Madlibs'

class TestMadlibs < RUNIT::TestCase
  def testStoryTemplate()
    # parse simple story
    # e.g. "Our favorite language is ((a gemstone))."
    template = "Our favorite language is ((a gemstone))."
    story = Story.new(template)

    # should return a Story with  a symbol name='a gemstome' and alias=nil
    assert_equals(1, story.placeholders.size)
    assert_not_nil(story.placeholders[0])
    assert_equals("a gemstone", story.placeholders[0].display_name)
  end

  def testStoryTemplateWithAlias()
    # parse story with name alias
    # e.g. "Our favorite language is ((gem:a gemstone)). We think ((gem)) 
is
    #         better than ((a gemstone))."
    template = "Our favorite language is ((gem:a gemstone)). "
    template += "We think ((gem)) is better then ((a gemstone))."
    story = Story.new(template)

    # should return a Story with 2 symbole
    # Symbol 1: name = 'gem' alias='a gemstome'
    # Symbol 2: name = 'a gemstome'
    assert_equals(2, story.placeholders.size)
    assert_not_nil(story.placeholders[0])
    assert_equals("gem", story.placeholders[0].name)
    assert_equals("a gemstone", story.placeholders[0].display_name)
    assert_not_nil(story.placeholders[1])
    assert_equals("a gemstone", story.placeholders[1].name)
    assert_equals("a gemstone", story.placeholders[1].display_name)
  end

  def testStoryGeneration()
    # give:    "Our favorite language is ((a gemstone))."
    # input:   gemstone = Ruby
    # result:  Our favorite language is Ruby."
    String template = "Our favorite language is ((a gemstone))."
    story = Story.new(template)
    story.placeholders[0].value = "Ruby"
    assert_equals("Our favorite language is Ruby.", story.to_s())
  end

  def testStoryGenerationWithAlias()
    # given:    "Our favorite language is ((gem:a gemstone)). 
    #                  We think ((gem)) is better than ((a gemstone))."    

    # input:    a gemstone = Ruby, a genstone = Emerald
    # given:    "Our favorite language is Ruby. 
    #                  We think Ruby is better than Emerald." 
    template = "Our favorite language is ((gem:a gemstone)). "
    template += "We think ((gem)) is better then ((a gemstone))."
    story = Story.new(template)
    story.placeholders[0].value = "Ruby"
    story.placeholders[1].value = "Emerald"
    assert_equals("Our favorite language is Ruby. We think Ruby is better 
then Emerald.", story.to_s())
  end
end

if $0 == __FILE__
  require 'runit/cui/testrunner'
  RUNIT::CUI::TestRunner.run(TestMadlibs.suite)
end