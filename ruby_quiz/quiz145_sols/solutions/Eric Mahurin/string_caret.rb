class StringCaret
    # cursor/caret is between char i-1 and i
    def initialize(data="", i=0)
        @data = data
        @i = i
    end
    def insert_before(ch)
        @data[@i,0] = ("" << ch)
        @i += 1
    end
    def insert_after(ch)
        @data[@i,0] = ("" << ch)
    end
    def delete_before
        @i.nonzero? and @data.slice!(@i-=1)
    end
    def delete_after
        @data.slice!(@i)
    end
    def left
        @i.nonzero? and @i-=1
    end
    def right
        @i<@data.length and @i+=1
    end
    def up
        while @i.nonzero?
            @i -= 1
            break(true) if @data[@i]==?\n
        end
    end
    def down
        while @i<@data.length
            break(@i+=1) if @data[@i]==?\n
            @i += 1
        end
    end
end
