#Oh, I love you SyncEnumerator, but you're just so impractically slow. A quick test suggest this is about 10,000 times faster. YMMV
#Works as long as the shortest of the two arguments responds to [] in the same way as an array and both enums respond to size()
#(if both enums are the same length, pass in the array first).
class ArraySyncEnumerator
    include Enumerable
    def initialize(a,b)
        @a,@b = a,b
    end
    def each
        if @a.size <= @b.size
            @b.each_with_index {|x,i|
                yield @a[i], x
            }
        else
            @a.each_with_index {|x,i|
                yield x, @b[i]
            }
        end
    end
end