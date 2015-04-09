class JIXPlayerD < Player
    WIN = {:paper => :scissors, :rock => :paper , :scissors => :rock}
    def initialize( opponent )
        @mk=Hash.new
        @last=[nil]*10
    end

    def choose
        out = []
        0.upto(@last.size-2) do |z|

            if !@last[z].nil?
                nodekey = @last[z..-1].map do |i|
                    i[0].to_s+"-"+i[1].to_s
                    #i[1].to_s
                end.join(",")
            out << @mk[nodekey] if @mk[nodekey]

            end
        end

        return [:paper,:rock,:scissors][rand(3)] if out == []

        out.sort_by{|z| - z.dfm}
        out[0].choose
    end

    def result( you, them, win_lose_or_draw )


        0.upto(@last.size-2) do |z|
            if !@last[z].nil?
                nodekey = @last[z..-1].map do |i|
                    i[0].to_s+"-"+i[1].to_s
                    #i[1].to_s
                end.join(",")
            @mk[nodekey]= MKNode.new if !@mk[nodekey]
            @mk[nodekey]<< WIN[them]
            end
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
        def dfm
            mid = (@paper+@rock+@scissors)/3.0
            (mid-@paper).abs+(mid-@rock).abs+(mid-@scissors).abs+mid
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
            "#<JIXPlayerDM::MKNode --- >"
            else
            "#<JIXPlayerDM::MKNode p{#{@paper/max}} r{#{@rock/max}} s{#{@scissors/max}} dfm{#{dfm}}>"
            end
        end
    end 
end
