class Amb
  class ExhaustedError < RuntimeError; end

  def initialize
    @fail = proc { fail ExhaustedError, "amb tree exhausted" }
  end

  def choose(*choices)
    prev_fail = @fail
    callcc { |sk|
      choices.each { |choice|
      	callcc { |fk|
      	  @fail = proc {
      	    @fail = prev_fail
      	    fk.call(:fail)
      	  }
      	  if choice.respond_to? :call
      	    sk.call(choice.call)
      	  else
      	    sk.call(choice)
      	  end
      	}
      }
      @fail.call
    }
  end

  def failure
    choose
  end

  def assert(cond)
    failure unless cond
  end
end
