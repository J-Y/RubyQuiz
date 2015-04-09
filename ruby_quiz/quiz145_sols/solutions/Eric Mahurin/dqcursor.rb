require 'dqstring'

class DQCursor
    def initialize
        @data = DQString.new
        @nafter = 0
    end
    def insert_before(ch)
        @data << ch
    end
    def insert_after(ch)
        @nafter += 1
        @data >> ch
    end
    def delete_before
        @data.length>@nafter and @data.pop
    end
    def delete_after
        @nafter.nonzero? and (@nafter-=1; @data.shift)
    end
    def left
        @data.length>@nafter and (@nafter+=1; @data >> @data.pop)
    end
    def right
        @nafter.nonzero? and (@nafter-=1; @data << @data.shift)
    end
    def up
        nbefore = @data.length-@nafter
        while nbefore.nonzero?
            nbefore -= 1
            @data >> (ch=@data.pop)
            return(true) if ch==?\n
        end
    ensure
        @nafter=@data.length-nbefore
    end
    def down
        while @nafter.nonzero?
            @nafter -= 1
            @data << (ch=@data.shift)
            return(true) if ch==?\n
        end
    end
end
