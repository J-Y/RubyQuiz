module AlphaBeta
  INFINITY = 1.0 / 0.0

  # Takes a state iterator and the maximum search depth and returns
  # the best possible value and the best operation to execute.
  #
  # A state should implement
  # * #each_successor (yield every successor state and the action that leads to the state)
  # * #value (the heuristic that values the state)
  # * #final? (true iff no successor states can be generated. See State#final?)
  def alpha_beta(state, maxdepth = 10, alpha = -INFINITY, beta = INFINITY)
    return state.value, nil if (maxdepth == 0) or state.final?

    best_operation = nil
    state.each_successor do | new_state, operation |
      val = -alpha_beta(new_state, maxdepth - 1, -beta, -alpha)[0]

      return beta, nil if (val >= beta)
      if (val > alpha)
        alpha = val
        best_operation = operation
      end    
    end

    return alpha, best_operation
  end

  # Takes a state iterator and the maximum search depth and returns
  # the best possible value and the best operation to execute.
  #
  # This is the randomized version that creates all successor states and shuffles them.
  #
  # A state should implement
  # * #each_successor (yield every successor state and the action that leads to the state)
  # * #value (the heuristic that values the state)
  # * #final? (true iff no successor states can be generated. See State#final?)
  def alpha_beta_r(state, maxdepth = 10, alpha = -INFINITY, beta = INFINITY)
    return state.value, nil if (maxdepth == 0) or state.final?
    best_operation = nil
    successor_states = []
    state.each_successor do | *cs | successor_states << cs end
    
    successor_states.sort_by{rand}.each do | new_state, operation |
      val = -alpha_beta_r(new_state, maxdepth - 1, -beta, -alpha)[0]

      return beta, nil if (val >= beta)
      if (val > alpha)
        alpha = val
        best_operation = operation
      end    
    end

    return alpha, best_operation
  end

  require 'timeout'
  # Repeatedly does a deeper #alpha_beta_r search until time in seconds is over.
  # Returns the deepest result so far.
  def alpha_beta_timed(state, time, min_depth = 3)
    result = alpha_beta_r(state, 1)
#   puts "Calculated to depth 1"
    begin
      timeout(time) do
        depth = min_depth
        loop do
          result = alpha_beta_r(state, depth)
#          puts "Calculated to depth #{depth}"
          depth += 1
        end      
      end
    rescue TimeoutError
    end
    return result
  end
end
