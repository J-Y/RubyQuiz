# (c) Copyright 2007 Florian Aßmann. All Rights Reserved.

require 'test/unit'

module NamePicker
  USE = 'Test'
end

class LuckyFilter_Test < Test::Unit::TestCase
  require 'lucky_filter'

  def setup

    @lf = NamePicker::LuckyFilter.new Array[
      [ 'Name', 'Company' ],
      [ 'Florian Assmann', 'Oniversus Media' ],
      [ 'Bill Gates', 'Microsoft' ],
      [ 'Steve Jobs', 'Apple' ]
    ]

    @controller = Object.new
    def @controller.method_missing method_sym, *args
      ( @missed ||= Hash.new )[ method_sym ] = args
    end

  end
  def teardown
    @lf.send :reset!
  end

  def test_pick_for
    history = Array.new

    @lf.pick_for @controller
    missed = @controller.instance_variable_get( :@missed )
    assert_instance_of Array, cur = missed[ :recieved? ],
    'Should be an instance of Array.'
    assert_instance_of Hash, cur.first,
    'Should be an instance of Hash.'
    assert ! history.include?( cur.first ),
    'Should not already be picked.'
    history << cur.first

    @lf.pick_for @controller
    assert_instance_of Array, cur = missed[ :recieved? ],
    'Should be an instance of Array.'
    assert_instance_of Hash, cur.first,
    'Should be an instance of Hash.'
    assert ! history.include?( cur.first ),
    'Should not already be picked.'
    history << cur.first

    @lf.pick_for @controller
    assert_instance_of Array, cur = missed[ :recieved? ],
    'Should be an instance of Array.'
    assert_instance_of Hash, cur.first,
    'Should be an instance of Hash.'
    assert ! history.include?( cur.first ),
    'Should not already be picked.'

    assert_raises IndexError, 'No record should be left.' do
      @lf.pick_for @controller
    end
  end
  def test_lucky
    assert_instance_of Array, winners = @lf.lucky,
    '@lf.lucky should return an instance of Array.'
    assert winners.empty?,
    '@lf.lucky should be empty.'

    @lf.pick_for @controller
    assert_instance_of Array, winners = @lf.lucky,
    '@lf.lucky should return an instance of Array.'
    assert_equal 1, winners.size,
    '@lf.lucky should be grown by 1.'
  end
  def test_unlucky
    assert_instance_of Array, loosers = @lf.unlucky,
    '@lf.unlucky should return an instance of Array.'
    assert_equal 3, loosers.size,
    '@lf.unlucky should have its original size of 3.'

    @lf.pick_for @controller
    assert_instance_of Array, loosers = @lf.unlucky,
    '@lf.unlucky should return an instance of Array.'
    assert_equal 2, loosers.size,
    '@lf.unlucky should be shrinked by 1.'
  end
  def test_delivered_to?
    loosers = @lf.instance_variable_get :@unlucky

    assert @lf.send( :delivered_to?, @controller, loosers.first ),
    'Should return the result of @controller.recieved?'
    missed = @controller.instance_variable_get :@missed

    assert_instance_of Hash, last = missed[ :recieved? ].first,
    'Should be instance of Hash for attendee.'
    assert @lf.send( :delivered_to?, @controller, loosers.last ),
    'Should return the result of @controller.recieved?'
    assert_not_equal last, missed[ :recieved? ].first,
    'Should not be the last delivered value.'
  end
  def test_reset!
    assert_equal NamePicker::LuckyFilter::EOD, File.size( DATA.path ),
    'Should not have attached data.'
    assert @lf.lucky.empty?,
    'Should have no winners.'

    @lf.pick_for @controller
    assert_not_equal NamePicker::LuckyFilter::EOD, File.size( DATA.path ),
    'Should have attached data.'
    assert_equal 1, @lf.lucky.size,
    'Should have 1 winner.'

    @lf.send :reset!
    assert_equal NamePicker::LuckyFilter::EOD, File.size( DATA.path ),
    'Should not have attached data.'
    assert @lf.lucky.empty?,
    'Should have no winners.'
  end

  def test_initialize
    assert_instance_of Array, @lf.instance_variable_get( :@attributes ),
    '@attributes should be an instance of Array'
    assert_instance_of Hash, @lf.instance_variable_get( :@attendees ),
    '@attendees should be an instance of Hash'
    assert_instance_of Array, @lf.instance_variable_get( :@unlucky ),
    '@unlucky should be an instance of Array'
  end

end

require 'test/unit/ui/console/testrunner'
Test::Unit::UI::Console::TestRunner.new LuckyFilter_Test

__END__
