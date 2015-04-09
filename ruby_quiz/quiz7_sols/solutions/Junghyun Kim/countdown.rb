## Code Begin##
def f(target, values)
        return 0,"0" if  values.nil? or values.length == 0
        return (target-values[0]).abs, "#{values[0]}" if values.length == 1

        mgap,mexpr = 1000, " "
        for i  in 0 ... values.length
                values2 = Array.new(values)
                value = values2.delete_at(i)


                    # For +
                gap, expr = f(target - value, values2)
                mgap,mexpr=gap, "#{expr}+#{value}" if gap <mgap
                break if mgap == 0

                # For -
                gap,expr = f(value-target, values2)
                mgap,mexpr=gap, "#{value}-#{expr}" if gap <mgap
                break if mgap == 0

                gap,expr = f(target+value, values2)
                mgap,mexpr=gap, "#{expr}-#{value}" if gap <mgap
                break if mgap == 0

                #For  *
                if value != 0
                        gap,expr = f(target/value, values2)
                        mgap,mexpr=gap, "(#{expr})*#{value}" if gap <mgap
                        break if mgap == 0
                end

                # For /
                if target != 0
                        gap,expr = f(value/target, values2)
                        mgap,mexpr=gap, "#{value}/(#{expr})" if gap <mgap
                        break if mgap == 0
                end

                gap,expr = f(target*value, values2)
                mgap,mexpr=gap, "(#{expr})/#{value}" if gap <mgap
                break if mgap == 0

        end
        return mgap, mexpr
end


def countDown(target, values)
        gap,expr = f(target.to_f, values.collect {|v| v.to_f})
        print "gap = #{gap}\n"
        print "expr = ",expr,"\n"
end

#sample
countDown(926, [75, 2, 8, 5, 10, 10])

## Code End##
