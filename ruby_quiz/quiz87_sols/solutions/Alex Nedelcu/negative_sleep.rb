class Computation
    def initialize(&computation)
        @comp = []
        @comp << computation
        @rev = 0
    end

    def run
        @comp.each do |runnable|
            if runnable.kind_of? Computation
                runnable.run
            else
                runnable.call
            end
        end
    end

    def +(ref)
        t = self
        ref.instance_eval { add_myself(t) }
        self
    end

    protected
    def add_myself(target)
        ref = self
        target.instance_eval do                  if @rev == 0
                @comp << ref
            else
                @comp.unshift ref
                @rev -= 1
            end
        end
    end
end

class Sleep < Computation
    alias old_init initialize
    alias old_add_myself add_myself
    attr_reader :seconds

    def initialize(seconds)
        old_init do   sleep(seconds > 0 ? seconds : -seconds); end
        @seconds = seconds
    end

    protected
    def add_myself(target)
        ref = self
        target.instance_eval do
            @rev = 2 if ref.kind_of? Sleep and ref.seconds < 0
        end
        old_add_myself(target)
    end
end
