# (c) Copyright 2007 Florian Aßmann. All Rights Reserved.

raise RuntimeError, 'TODO: Backup...'

require 'test/unit'

class DataSource_Test < Test::Unit::TestCase

  def setup

    @ds = DataSource.new Array[
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
    @ds.send :_reset!
  end

  def test_pick_for
    history = Array.new

    @ds.pick_for @controller
    missed = @controller.instance_variable_get( :@missed )
    assert_instance_of Array, cur = missed[ :recieved? ],
    'Should be an instance of Array.'
    assert_instance_of Hash, cur.first,
    'Should be an instance of Hash.'
    assert ! history.include?( cur.first ),
    'Should not already be picked.'
    history << cur.first

    @ds.pick_for @controller
    assert_instance_of Array, cur = missed[ :recieved? ],
    'Should be an instance of Array.'
    assert_instance_of Hash, cur.first,
    'Should be an instance of Hash.'
    assert ! history.include?( cur.first ),
    'Should not already be picked.'
    history << cur.first

    @ds.pick_for @controller
    assert_instance_of Array, cur = missed[ :recieved? ],
    'Should be an instance of Array.'
    assert_instance_of Hash, cur.first,
    'Should be an instance of Hash.'
    assert ! history.include?( cur.first ),
    'Should not already be picked.'

    assert_raises IndexError, 'No record should be left.' do
      @ds.pick_for @controller
    end
  end
  def test_winners
    assert_instance_of Array, winners = @ds.winners,
    '@ds.winners should return an instance of Array.'
    assert winners.empty?,
    '@ds.winners should be empty.'

    @ds.pick_for @controller
    assert_instance_of Array, winners = @ds.winners,
    '@ds.winners should return an instance of Array.'
    assert_equal 1, winners.size,
    '@ds.winners should be grown by 1.'
  end
  def test_loosers
    assert_instance_of Array, loosers = @ds.loosers,
    '@ds.loosers should return an instance of Array.'
    assert_equal 3, loosers.size,
    '@ds.loosers should have its original size of 3.'

    @ds.pick_for @controller
    assert_instance_of Array, loosers = @ds.loosers,
    '@ds.loosers should return an instance of Array.'
    assert_equal 2, loosers.size,
    '@ds.loosers should be shrinked by 1.'
  end
  def test__delivered?
    loosers = @ds.instance_variable_get :@loosers

    assert @ds.send( :_delivered?, @controller, loosers.first ),
    'Should return the result of @controller.recieved?'
    missed = @controller.instance_variable_get :@missed

    assert_instance_of Hash, last = missed[ :recieved? ].first,
    'Should be instance of Hash for attendee.'
    assert @ds.send( :_delivered?, @controller, loosers.last ),
    'Should return the result of @controller.recieved?'
    assert_not_equal last, missed[ :recieved? ].first,
    'Should not be the last delivered value.'
  end
  def test__reset!
    assert_equal DataSource::EOD, File.size( DATA.path ),
    'Should not have attached data.'
    assert @ds.winners.empty?,
    'Should have no winners.'

    @ds.pick_for @controller
    assert_not_equal DataSource::EOD, File.size( DATA.path ),
    'Should have attached data.'
    assert_equal 1, @ds.winners.size,
    'Should have 1 winner.'

    @ds.send :_reset!
    assert_equal DataSource::EOD, File.size( DATA.path ),
    'Should not have attached data.'
    assert @ds.winners.empty?,
    'Should have no winners.'
  end

  def test_initialize
    assert_instance_of Array, @ds.instance_variable_get( :@attributes ),
    '@attributes should be an instance of Array'
    assert_instance_of Hash, @ds.instance_variable_get( :@attendees ),
    '@attendees should be an instance of Hash'
    assert_instance_of Array, @ds.instance_variable_get( :@loosers ),
    '@loosers should be an instance of Array'
  end

end

require 'test/unit/ui/console/testrunner'
Test::Unit::UI::Console::TestRunner.new( DataSource_Test )
