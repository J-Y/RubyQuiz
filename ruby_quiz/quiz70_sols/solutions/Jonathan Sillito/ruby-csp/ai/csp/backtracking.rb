# = ai/csp/backtracking.rb
# Copyright (C) 2005 Jonathan Sillito, sillito@gmail.com
#
# Written and maintained by Jonathan Sillito. Please report bugs, make
# suggestions or otherwise get involved by email at sillito@gmail.com.
#
# See AI::CSP for an overview and examples. See AI::CSP::Backtracking
# for details.
#
# $Id: $

require 'ai/csp'

module AI
module CSP

    # = Backtracking
    #
    # Implements chronological backtracking for CSPs. If propagation
    # is turned on, this amounts roughly to forward checking
    # (depending on the constraints).
    #
    # See AI::CSP for an overview and more examples. 
    #
    class Backtracking
        
        # For recording statistics
        attr_reader :constraint_checks
        attr_reader :nodes_explored
        attr_reader :solutions
        attr_reader :time
        attr_reader :description

        # var_ordering can be STATIC or FAIL_FIRST (note that
        # FAIL_FIRST, or dynamic variable orderings generally are only
        # useful when propagation is true).
        def initialize(propagate=true, var_ordering=STATIC)
            @propagate, @var_ordering = propagate, var_ordering
            ordering = ["static","ff"][@var_ordering]
            @description = "BT(prop=#{@propagate} ord=#{ordering})"
        end

        # Calls block with each solution, where a solution is simply the
        # problem with all variables instantiated.
        def each_solution(csp)
            @constraint_checks = @nodes_explored = @solutions = 0
            # reset all constraint check stats
            csp.each_constraint {|con| con.checks = 0 }
            start = Time.now
            
            each(csp, 0) { |solution|
                @solutions += 1
                @time = Time.now - start
                yield solution
            }
            
            @time = Time.now - start
            csp.each_constraint {|con| @constraint_checks += con.checks }
        end
        
        # Returns first solution, or nil if none found.
        def first_solution(csp)
            each_solution(csp) { |solution|
                return solution
            }
            nil
        end
        
        def to_s
            [@description, 
             "checks    = #{@constraint_checks}",
             "nodes     = #{@nodes_explored}",
             "solutions = #{@solutions}",
             "time      = #{@time}"].join("\n")
        end
        
        protected
        
        def valid?(variable, csp, level)
            csp.each_constraint(variable) { |constraint|
                if constraint.checkable?
                    return false unless constraint.check?
                elsif @propagate
                    return false unless constraint.propagate(variable, level)
                end
            }
            true
        end
        
        def undo_propagate(csp, level)
            # This could be made more efficient by storing a list of pruned
            # variables by level.
            csp.each_uninstantiated_variable { |variable|
                variable.unprune(level) if variable.pruned?(level)
            }
        end

        def pick_variable(csp,level)
            case @var_ordering
            when STATIC
                csp.variables[level]
            when FAIL_FIRST
                min = selected = nil
                csp.each_uninstantiated_variable { |variable|
                    size = variable.domain_size(level)
                    if min == nil or min > size
                        min = size
                        selected = variable
                    end
                }
                selected
            else raise "unknown variable ordering #{@var_ordering}"
            end
        end

        def each(csp,level,&block)
            return yield(csp) if level >= csp.variables.length
            
            variable = pick_variable(csp,level)
            values = variable.each_value(level) {|value| value}
            
            variable.each_value(level) { |value|
                @nodes_explored += 1
                variable.value = value
                each(csp, level+1, &block) if valid?(variable,csp,level)
                undo_propagate(csp, level) if @propagate
            }
            variable.value = UNSET
        end     
    end

end
end
