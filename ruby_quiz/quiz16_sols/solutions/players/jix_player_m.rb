class JIXPlayerM < Player
    WIN = {:paper => :scissors, :rock => :paper , :scissors => :rock}
    def initialize( opponent )
        @mk=Hash.new
        @last=[nil]*3 # try other values
    end
    def choose
        if !@last[0].nil?
            nodekey = @last.map do |i|
                i[0].to_s+"-"+i[1].to_s
            end.join(",")
            @mk[nodekey]= MKNode.new if !@mk[nodekey]
            @mk[nodekey].choose
        else
            [:paper,:rock,:scissors][rand(3)]
        end
    end

    def result( you, them, win_lose_or_draw )

        if !@last[0].nil?
            nodekey = @last.map do |i|
                i[0].to_s+"-"+i[1].to_s
            end.join(",")
            @mk[nodekey]= MKNode.new if !@mk[nodekey]
            @mk[nodekey]<< WIN[them]
        end
        @last[0,1]=[]
        @last<< [you,them]

    end
    private
    class MKNode
        def initialize(paper=0,rock=0,scissors=0)
            @paper=paper
            @rock=rock
            @scissors=scissors
        end
        def choose
            if @paper+@rock+@scissors == 0
                [:paper,:rock,:scissors][rand(3)]
            else
                rnd = rand(@paper+@rock+@scissors)
                if rnd < @paper
                    :paper
                elsif rnd < @paper+@rock
                    :rock
                else
                    :scissors
                end
            end
        end
        def <<(x)
            case x
            when :paper
                @paper+=1
            when :rock
                @rock+=1
            when :scissors
                @scissors+=1
            end
        end
        def inspect
            max = @paper+@rock+@scissors.to_f
            if max == 0
            "#<JIXPlayerM::MKNode --- >"
            else
            "#<JIXPlayerM::MKNode p{#{@paper/max}} r{#{@rock/max}} s{#{@scissors/max}} >"
            end
        end
    end 
end
