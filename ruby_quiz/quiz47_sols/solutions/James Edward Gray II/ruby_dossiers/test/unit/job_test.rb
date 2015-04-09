require File.dirname(__FILE__) + '/../test_helper'

class JobTest < Test::Unit::TestCase
  fixtures :jobs

  def setup
    @job = Job.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Job,  @job
  end
end
