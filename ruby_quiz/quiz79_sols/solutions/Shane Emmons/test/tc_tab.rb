#!/usr/local/bin/ruby -w

require 'test/unit'

require 'lib/tab'

class TC_Tab < Test::Unit::TestCase

  def setup
    test_construction
  end

  def test_construction
    @tab = Tab.new('tabs/Em.tab')

    assert_not_nil(@tab)
    assert_instance_of(Tab, @tab)
    assert_equal('tabs/Em.tab', @tab.file)
    assert_nil(@tab.music)
  end

  def test_read
    @tab.parse
    assert_equal( [ '------', '0-----', '------', '-2----', '------',
                    '--2---', '------', '---0--', '------', '----0-',
                    '------', '-----0'
                  ], @tab.music )

    @tab.parse('tabs/AmStrum.tab')
    assert_equal( [ '------', '-0----', '------', '--2---', '------',
                    '---2--', '------', '----1-', '------', '-----0',
                    '------', '------', '------', '-02210', '------',
                    '------', '------', '------', '------', '------',
                    '------', '------', '------', '------'
                  ], @tab.music )
  end

end
