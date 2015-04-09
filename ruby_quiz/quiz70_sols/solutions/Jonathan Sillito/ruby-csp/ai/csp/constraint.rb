# = ai/csp/constraint.rb
# Copyright (C) 2005 Jonathan Sillito, sillito@gmail.com
#
# Written and maintained by Jonathan Sillito. Please report bugs, make
# suggestions or otherwise get involved by email at sillito@gmail.com.
#
# See AI::CSP for an overview and examples. See AI::CSP::Constraint
# for details. AI::CSP::AllDifferent and AI::CSP::AllSame are examples
# of specialized constraint types, with more aggressive propagation.
#
# $Id: $

require 'set'

module AI
module CSP

    # A generic constraint on a number of variables. The propagate
    # method, performs forward checking, however many subclasses
    # (implementing specialized constraing types) will want override
    # this method and provide more efficient pruning and possibly
    # enforce stronger consistency.
    #
    # See AI::CSP for an overview and more examples. 
    #
    class Constraint
        attr_reader :variables
        attr_accessor :checks

        def initialize(*variables, &block)
            if block.arity != variables.length and block.arity != -1
                raise 'error: # of variables != arity of the check proc'
            end
            @variables, @block, @checks = variables, block, 0
        end

        # Returns true if all variables in this constraint have been
        # instantiated, and false otherwise.
        def checkable?
            @variables.each { |variable|
                return false unless variable.instantiated?
            }
            true
        end

        # Checks this constraint on the current values for the
        # participating variables.
        def check?
            raise 'uncheckable' unless checkable?
            @checks += 1
            values = @variables.collect {|v| v.value}
            @block.call(*values)
        end

        # Performs generic forward checking when all but one of the
        # participating variables has been instantiated.  Subclasses
        # of course can do something more clever.  The specified
        # variable is the most recently instantiated variable.
        def propagate(variable, level)
            return true unless v = forward_checkable?

            v.each_value_with_index(level) { |value,index|
                v.value = value
                v.prune(level, index) unless check?
            }
            v.value = UNSET
            not v.domain_empty?(level)
        end

        # Returns true if exactly one of the variables participating
        # in this constraint are uninstantiated.
        def forward_checkable?
            vars = uninstantiated_variables
            vars.length == 1 ? vars[0] : nil
        end

        def to_s
            (@variables.collect {|v| v.name}).join("-")
        end

        protected

        # Returns an array containing all uninstantiated variables
        # that participate in this constraint.
        def uninstantiated_variables
            @variables.select {|v| not v.instantiated?}
        end
    end

    # An example of a specialized constraint type. It ensures that all
    # participating variables have different values.
    class AllDifferent < Constraint
        def initialize(*variables)
            super(*variables) {|*values|
                unique_values = Set.new(values)
                unique_values.length == values.length
            }
        end

        def propagate(variable, level)
            value = variable.value
            uninstantiated_variables.each { |v|
                value_index = v.domain.index(value)
                if value_index.nil? or v.pruned?(level,value_index)
                    next
                end
                v.prune(level,value_index)
                return false if v.domain_empty?(level)
            }
            true
        end
    end

    # Ensures that all participating variables have the same value
    # (maybe useless).
    class AllSame < Constraint
        def initialize(*variables)
            super(*variables) { |*vals|
                value = vals[0]
                val = nil
                vals.each { |val|
                    break unless value == val
                }
                value == val
            }
        end

        # While expensive, this can prune huge amounts from the search
        # space and will generally be a net performance gain.
        def propagate(variable, level)
            uninstantiated_variables.each {|v|
                v.each_value_with_index(level) { |value, index|
                    v.prune(level, index) unless value == variable.value
                }
                return false if v.domain_empty?
            }
            true
        end
    end

end
end
