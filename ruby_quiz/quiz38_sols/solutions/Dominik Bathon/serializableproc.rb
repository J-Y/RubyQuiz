require "delegate"
require "yaml"

class SProc < DelegateClass(Proc)

    attr_reader :proc_src

    def initialize(proc_src)
        super(eval("Proc.new { #{proc_src} }"))
        @proc_src = proc_src
    end

    def ==(other)
        @proc_src == other.proc_src rescue false
    end

    def inspect
        "#<SProc: #{@proc_src.inspect}>"
    end
    alias :to_s :inspect

    def marshal_dump
        @proc_src
    end

    def marshal_load(proc_src)
        initialize(proc_src)
    end

    def to_yaml(opts = {})
        YAML::quick_emit(self.object_id, opts) { |out|
            out.map("!rubyquiz.com,2005/SProc" ) { |map|
                map.add("proc_src", @proc_src)
            }
        }
    end

end

YAML.add_domain_type("rubyquiz.com,2005", "SProc") { |type, val|
    SProc.new(val["proc_src"])
}

if $0 == __FILE__
    require "pstore"

    code = SProc.new %q{ |*args|
        puts "Hello world"
        print "Args: "
        p args
    }

    orig = code

    code.call(1)

    File.open("proc.marshalled", "w") { |file| Marshal.dump(code, file) }
    code = File.open("proc.marshalled") { |file| Marshal.load(file) }

    code.call(2)

    store = PStore.new("proc.pstore")
    store.transaction do
        store["proc"] = code
    end
    store.transaction do
        code = store["proc"]
    end

    code.call(3)

    File.open("proc.yaml", "w") { |file| YAML.dump(code, file) }
    code = File.open("proc.yaml") { |file| YAML.load(file) }

    code.call(4)

    p orig == code
end
