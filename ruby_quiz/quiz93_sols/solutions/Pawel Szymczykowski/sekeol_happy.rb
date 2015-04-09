class Integer
    @@happy = Hash.new {|h,k| h[k.to_key] = k.to_i.happiness}
    NS = [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

    def happiness
        return @@happy[to_key] if @@happy.has_key?(to_key)
        w, errlev = [self], false
        h = 0
        until errlev
            w << w[-1].happiness_step
            k = w[-1].to_key
            if @@happy.has_key?(k)
                w += (@@happy[k])
                errlev = true
            end
            errlev = ([0,2,3,4,5,6,8,9].include?(w[-1]) || (w.uniq.length < w.length))
        end
        @@happy[to_key] = w
    end

    def happy?; happiness[-1]==1; end
    protected
    def digitize; self.to_s.split(//).collect {|x| x.to_i}.delete_if {|x| x.zero?}; end
    def happiness_step; return 0 if digitize.nil?; digitize.inject(0) {|k,v| k + NS[v]}; end
    def to_key; self.digitize.sort.to_s rescue '0'; end
end


x = 1000000
mosthappy = [0,0]
until x.zero?
    hap = x.happiness
    if hap[-1]==1
        hapct = hap.inject(0) {|k,v| k + (v.happy? ? 1 : 0)}
        mosthappy=[hapct, x] if hapct>=mosthappy[0]
    end
    x -= 1
end
p mosthappy