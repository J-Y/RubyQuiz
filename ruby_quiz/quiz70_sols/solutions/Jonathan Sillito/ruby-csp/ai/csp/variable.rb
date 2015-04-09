# = ai/csp/variable.rb
# Copyright (C) 2005 Jonathan Sillito, sillito@gmail.com
#
# Written and maintained by Jonathan Sillito. Please report bugs, make
# suggestions or otherwise get involved by email at sillito@gmail.com.
#
# See AI::CSP for an overview and examples. See AI::CSP::Variable for
# details.
#
# $Id: $

module AI
module CSP

    # = Variables 
    #
    # A variable and its domain. Also supports instantiating the
    # variable and pruning values when propagating constraints.
    #
    # See AI::CSP for an overview and examples. 
    #
    class Variable

        # Just needs to be larger than the number of variables in problem
        MAXINT = 2**16

        attr_reader :name
        attr_reader :domain
        attr_accessor :value
        
        # domain must respond to .to_a
        def initialize(name, domain)
            @name, @domain, @value = name, domain.to_a, UNSET
            @pruned = [MAXINT] * @domain.length
            @sizes = [@domain.length] # domain size by level
        end
        
        def instantiated?
            @value != UNSET
        end

        # Calls provided block with each value that is valid at the
        # specified level.
        def each_value(level=0)
            each_value_with_index(level) {|value, i| yield value}
        end

        # Calls provided block with each value (and its index) that is
        # valid at the specified level.
        def each_value_with_index(level=0)
            @domain.each_with_index {|value, index|
                yield value,index if not pruned?(level, index)
            }
        end

        # Marks the value at value_index as pruned at the specified
        # level.
        def prune(level, value_index)
            if @sizes.length <= level
                last = @sizes[-1]
                (level).downto(@sizes.length) {|i|
                    @sizes[i] = last
                }
            end

            @pruned[value_index] = level
            @sizes[level] -= 1
        end

        # Unprunes all values that were pruned at specified level or
        # at higher (deeper) levels.
        def unprune(level)
            @sizes = (level==0 ? [@domain.length] : @sizes[0...level])
            @pruned.collect! {|value| value >= level ? MAXINT : value}
        end

        # Returns true if the value at value_index has been pruned at
        # this level (or at any previous levels). If no value_index is
        # specified, returns true if any values have been pruned at
        # the specified level.
        def pruned?(level, value_index=nil)
            if value_index.nil?
                if level == 0 then @domain.length > @sizes[level]
                else @sizes[level] != @sizes[level-1]
                end
            else
                @pruned[value_index] <= level
            end
        end
 
        def domain_size(level=0)
            if level >= @sizes.length then @sizes[-1]
            else @sizes[level]
            end
        end

        def domain_empty?(level=0)
            domain_size(level) == 0
        end
    end
end
end
