# characters can be in either of these ranges:
#     gapped : @begin...length, 0...@end
#     contiguous : @begin...@end
# inheriting String only for memory efficiency
# inherited methods won't necessarily make sense

class DQString < String
    def initialize(data="")
        @begin = 0
        @end = data.length
        super(data)
    end
    def inspect
        "#<DQString: begin=#{@begin}, end=#{@end}, #{super}>"
    end
    def length
        if (len = @end-@begin)>=0
            len
        else
            super+len
        end
    end
    def << (ch)
        if @end==size
            if @begin>1
                # use the front, making a gap in the middle
                self[0] = ch
                @end = 1
                self
            else
                @end += 1
                # let ruby realloc when needed
                super(ch)
            end
        else
            self[@end] = ch
            @end += 1
            if @end==@begin
                # double the size when the gap becomes empty
                @begin += size
                self.replace(self+self)
            else
                self
            end
        end
    end
    def >> (ch)
        if @begin.zero?
            @begin = size-1
            if @end<@begin
                # use the back, making a gap in the middle
                self
            else
                # double the size to make room at the front
                @end += size
                self.replace(self+self)
            end
        else
            @begin -= 1
            if @begin==@end
                # double the size when the gap becomes empty
                @begin += size
                self.replace(self+self)
            else
                self
            end
        end
    ensure
        self[@begin] = ch
    end
    def pop
        if @end==@begin
            nil
        else
            @end -= 1
            ch = self[@end]
            if (len = @end-@begin)>=0
                # remove excess trailing space if too much
                self.slice!(-len,len) if size-@end>(len<<1)
            elsif @end.zero?
                len = (@end=size)-@begin
                if @begin>(len<<1)
                    # remove excess leading space
                    self.slice!(0, len)
                    @begin -= len
                    @end -= len
                end
            end
            ch
        end
    end
    def shift
        if @begin==@end
            nil
        else
            ch = self[@begin]
            @begin += 1
            if (len = @end-@begin)>=0
                if @begin>(len<<1)
                    # remove excess leading space
                    self.slice!(0, len)
                    @begin -= len
                    @end -= len
                end
            elsif @begin==size
                # remove excess trailing space if too much
                self.slice!(-@end,@end) if (@end<<1)+len<0
                @begin = 0
            end
            ch
        end
    end
end
