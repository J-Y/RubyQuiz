require 'array_sync_enum'

#drys code out. Only acts on one 'line' at a time, by calling enumerating over the content
#however, if you pass in an array with multiple lines in each index, it can use that too.
#matches are based on the punctuation structure and word count of the lines.
#This works really well for the example given, but may not in other situations
class DRYer
    #you can restrict the maximum number of args that will go into a function
    #if you set this to infinite, any lines with matching spacing and number of 
    def initialize(arg_threshold=nil)
        @arg_threshold = arg_threshold
    end
    def with_matching_regexes(line, idx=0, &block)
        block.call(line)
        unless @arg_threshold && @arg_threshold >= 0 && line.reject {|x| String === x}.size >= @arg_threshold
            (idx...(line.size)).each {|i|
                if(/[\w\d]+/ === line[i])
                    x = line.dup
                    x[i] = /[\w\d]+/
                    with_matching_regexes(x, i+1, &block)
                end
            }
        end
    end
    def dry(input, output)
        #split each line into leading whitespace, content and trailing whitespace
        lines = input.map do |line|
            m = /(\s*)(.*)(\s*\n?)/.match(line)
            [m[1], m[2].split(/([^\w\d])/), m[3]]
        end
        count = Hash.new(0)
        warn "generating regexes"
        lines.each { |line| 
            $stderr.print '.'; $stderr.flush
            next unless line[1].any? {|x| !x.strip.empty?}
            #raise unless matching_regexes(line[1]).size == matching_regexes(line[1]).uniq.size
            #p matching_regexes(line[1])
            with_matching_regexes(line[1]) { |regex|
                next if regex.all? {|x| x == /[\w\d]+/ || x.strip.empty? }
                count[regex] += 1
            }
            #adds one to the whole line count
            #~ count[line[1]] += 1
            #adds one to the one word different count
            #~ line[1].each_with_index {|x,i|
                #~ next if x.strip.empty?
                #~ match = line[1].dup
                #~ match[i] = /[\w\d]*/
                #~ count[match] += 1
            #~ }
        }
        warn "sorting regexes"        
        sorted_matches = count.select {|a,b|
            b > 1
        }.sort_by { |a,b|
            #if the occurence count is the same, choose the one with the least regexes
            [-b, a.reject { |x| String === x}.size]
        }.collect { |a,b| 
            a
        }
        found_matches = []
        warn "modifying lines"        
        lines.each do |line|
            match = sorted_matches.find { |x| ArraySyncEnumerator.new(x, line[1]).all? {|a,b| a === b} }
            if(match)
                found_matches << match
                args = ArraySyncEnumerator.new(match, line[1]).reject {|a,b|
                    String === a
                }.collect { |a,b|
                    b.inspect
                }
                line[1] = call_function(function_name(match), args)
            else
                escape_line(line)
            end
        end
        functions = found_matches.uniq.map do |x|
            function_content(x)
        end
        create_output(functions, lines, output)        
    end
    def function_name(match)
        string = match.select { |x| String === x }.join
        string.gsub(/[^\w]+/,"_")
    end
    def function_content(match)
        content = "#{function_name(match)} = lambda do |"
        firstarg = true
        match.reject {|x| String === x}.each_with_index do |x,i|
            content << "," unless firstarg
            content << "arg#{i}"
            firstarg = false
        end
        content << "|\n    "
        argpos = 0
        while(argindex = match.index(/[\w\d]+/))
            content << '+' if argpos > 0
            if argindex > 0
                before = match[0...argindex].join
                if(before.size > 0)
                    content << before.inspect
                    content << '+'
                end
            end
            content << "arg#{argpos}"
            match = match[argindex+1..-1]
            argpos += 1
        end
        if(match.join.size > 0)
            content << '+' if argpos > 0
            content << match.join.inspect 
        end
        content << "\nend\n"
        content
    end    
    #outputs an erb file that will produce the input file
    #because
    def create_output(functions, lines, output)        
        #~ output.puts '<%'
        #~ output.puts functions
        functions.join.each {|fline| 
            output.puts '%' + fline
        }
        #~ output.puts "%>"
        output.print lines.join        
    end
    def escape_line(line)
        line[1] = line[1].join
        line[1].gsub!('<%','<%%')
        line[1].gsub!('<%','<%%')
        line[1].sub!(/^%/, '%%') if(line[0].empty?)
    end
    def call_function(function_name, args)
        '<%=' + function_name + '['+args.join(',')+']%>'        
    end    
end

#~ d = DRYer.new
#~ d.with_matching_regexes(["xx",",","yy"]) {|x| p x }
#~ exit

#evalable dryer - produces standalone ruby programs that can be either eval'd or run at the command line
#to produce the output.
class EvalDRYer < DRYer
    def create_output(functions, lines, output)
        output.puts functions
        special_key = "EOF"
        special_key = "EOF#{rand}" until [lines,functions].all? {|a| a.all? {|x| !x.include?(special_key) }}
        output.puts "lambda {|x|x.chomp!;(__FILE__ == $0)? print(x) : x }.call(<<-#{special_key})"
        output.print lines.join
        output.puts "\n"
        output.puts special_key
    end
    def escape_line(line)
        line[1] = line[1].join    
        line[1] = line[1].inspect[1..-2].gsub("\\t", "\t") #put tabs back in - they're safe and make it prettier
    end
    def call_function(function_name, args)
        '#{' + function_name + '['+args.join(',')+']}'    
    end    
end

if __FILE__ === $0
    require 'optparse'
    require 'ostruct'
    options = OpenStruct.new
    options.use_eval = false
    options.test_mode = false
    options.arg_threshold = nil
    p ARGV
    OptionParser.new do |opts|
        opts.banner = "Usage: dryer.rb [options]"
        opts.separator ""
        opts.separator "Creates an ERB file (or optionally a standalone program) that removes duplication and will reproduce the given input."
        opts.separator ""
        opts.separator "Specific options:"    
        
        opts.on("-t", "--threshold THRESHOLD", Integer,
                "Functions will have at most THRESHOLD arguments") do |threshold|
            options.arg_threshold = threshold
        end
        opts.on("-e", "--eval",
                "Outputs an eval-able/standalone ruby program instead of ERB output") do |test|
            options.use_eval = true
        end
        opts.on("--test",
                "Performs a complete round trip and verifies that output = input") do |test|
            options.test_mode = true
        end
        opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
        end        
    end.parse!(ARGV)
    
    if(options.test_mode)
        require 'stringio'
        input = ARGF.read
        program = ""
        if(options.use_eval)
            EvalDRYer.new.dry(input, StringIO.new(program))
            output = eval(program)
        else
            DRYer.new.dry(input, StringIO.new(program))
            require 'erb'
            output = ERB.new(program,nil,'%').result
        end
        puts output
        if input === output
            warn "Round trip successful"
            exit
        else
            warn "Round trip failed"
            input.split(//).each_with_index do |x,i|
                unless x == output[i..i]
                    warn "Failed at character #{i}"
                    break
                end
            end
            exit 1
        end
    else
        (options.use_eval ? EvalDRYer : DRYer).new(options.arg_threshold).dry(ARGF, $stdout)
    end
end