class Happy
    @@cache = []
    attr_accessor :num,:happy,:friends,:checked
    def initialize(num,friends=[])
        @num=num.to_i
        (return @@cache[@num]) if @@cache[@num]
        @friends=friends
        @happy=false
        check
        self
    end

    def check
        return @happy if @checked
        dig = @num.to_s.split("")
        dig = dig.map{|n| n.to_i }
        res = dig.inject(0){|sum,d| sum + d * d }
        if(res==1)
            @friends = []
            return save(true)
        else
            if(@friends.include?(res))
                return save(false)
            else
                h = Happy.new(res,@friends + [@num])
                if(@happy=h.happy)
                    @friends = h.friends + [h.num]
                    return save(true)
                else
                    return save(false)
                end
            end
        end
    end

    def save(happy)
        @happy=happy
        @checked=true
        @@cache[@num]=self
        self
    end
end
