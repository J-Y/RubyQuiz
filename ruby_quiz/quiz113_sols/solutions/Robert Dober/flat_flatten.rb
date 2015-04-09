# * Given a nested Array of Arrays, perform a flatten()-like operation that
# removes only the top level of nesting.  For example, [1, [2, [3]]] would become
# [1, 2, [3]].
# 
#...+....|....+....2....+....|....+....|....+....5....+....|....+....|....+....8
quiz.inject( [] ) { |a,e| a + ( Array === e ? e : [e] ) }
# or
# quiz.inject{|r,a|[*r]+[*a]}
