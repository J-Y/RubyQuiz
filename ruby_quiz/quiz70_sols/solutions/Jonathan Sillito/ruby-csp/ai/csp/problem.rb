# = ai/csp/problem.rb
# Copyright (C) 2005 Jonathan Sillito, sillito@gmail.com
#
# Written and maintained by Jonathan Sillito. Please report bugs, make
# suggestions or otherwise get involved by email at sillito@gmail.com.
#
# See AI::CSP for an overview and examples. See AI::CSP::Problem for
# details.
#
# $Id: $

module AI
module CSP

    # = Problem
    #
    # For modeling CSP problems in terms of variables (which have
    # domains) and constraints over those variables.
    #
    # See AI::CSP::Variable and AI::CSP::Constraint. Also, see AI::CSP
    # for an overview and examples.
    #
    class AI::CSP::Problem
        attr_reader :variables
        attr_reader :constraints
        
        def initialize(variables)
            @variables, @constraints = variables, [], {}
            @name_to_var, @var_to_con = {}, {}
            @variables.each { |variable|
                @name_to_var[variable.name] = variable
            }
        end

        # Calls provided block with each variable in the problem that
        # is currently uninstantiated.
        def each_uninstantiated_variable 
            @variables.each { |variable|
                yield variable unless variable.instantiated?
            }
        end
        
        # one of:
        #   add_constraint(constraint)
        #   add_constraint(v1, v2, ...) {|a,b,..| ...}
        #   add_constraint(vname1, vname2. ...) {|a,b,...| ...}
        def add_constraint(*variables, &block)
            if block_given?
                vars = variables.collect { |v|
                    v.kind_of?(Variable) ? v : @name_to_var[v]
                }
                con = Constraint.new(*vars, &block)
            elsif variables.length == 1 and variables[0].kind_of?(Constraint)
                con = variables[0]
            else
                raise 'Some usage message here ...'
            end
            
            @constraints << con
            con.variables.each {|v|
                cons = (@var_to_con[v] or [])
                @var_to_con[v] = cons + [con]
            }
            con
        end

        # Calls block with each constraint in the problem. If a
        # variable is specified, restricts this to constraints
        # involving that variable.
        def each_constraint(variable=nil, &block)
            if variable
                @var_to_con[variable].each(&block) if @var_to_con[variable]
            else
                @constraints.each(&block)
            end
        end

        def to_s
            results = ["vars=#{@variables.length} cons=#{@constraints.length}"]
            @variables.each_with_index { |variable, index|
                results << "#{variable.name} = #{variable.value}"
            }
            results.join("\n")
        end
    end

end
end
