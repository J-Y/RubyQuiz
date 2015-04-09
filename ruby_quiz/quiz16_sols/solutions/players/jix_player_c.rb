class JIXPlayerC < Player
    def initialize( opponent )
        @que=%w{paper rock rock scissors paper scissors}.map{|z|z.to_sym}
        @i=0
    end
    def choose
        @i+=1
        @i%=@que.size 
        @que[@i]
    end
end
