module Lisp
    module StandardFunctions
        def first(arr)
            arr[0]
        end
        def second(arr)
            arr[1]
        end
        def third(arr)
            arr[2]
        end
        def assoc(key, arr)
            arr.assoc(key)
        end
        def cddr(arr)
            arr[2..-1]
        end
        def mapcar(proc, arr)
            arr.collect do |x|
                proc.call(x)
            end
        end
        def apply(function, list)
            function.call(*list)
        end
        def eq(a, b)
            a == b
        end
        def push(object, arr)
            arr.unshift(object)
        end
        def list(*things)
            things
        end
        def not(expression)
            !expression
        end
        def and(*args)
            args.all? { |x| x }
        end
        def member(object, arr)
            arr.include?(object)
        end
        define_method "remove-if-not" do |proc, arr|
            arr.select {|x| proc.call(x) }
        end
        def append(*list)
            out = []
            list.each { |l| 
                out.concat(l)
            }
            out
        end
    end
    
    class LispList < Array
        attr_reader :flags
        def initialize(flags)
            raise "bad" unless flags
            @flags = flags
        end
        def to_lisp()
            "#{@flags}(#{collect {|x| x.to_lisp()}.join(" ")})"
        end
        def __compute_comma(out, lisp, local_vars, depth=1)
            each { |x|
		cin = nil
		depth.times { 
			newcin = x.flags[(cin||-1)+1..-1].index(",")
			if newcin
				cin = newcin + (cin||-1) + 1
			else
				cin = nil
				break
			end
		}
		if(cin)
                    if(x.flags[cin+1] == "@")
                        newflags = x.flags[cin+2..-1] 
                    else
                        newflags = x.flags[cin+1..-1]
                    end
                    if(LispList === x)
                        xx = LispList.new(newflags)
                        x.each { |y|
                            xx << y
                        }
                    else
                        xx = LispString.new(x, newflags)
                    end
                    yy = xx.compute(lisp, local_vars)
		    x.flags[0...cin].reverse.each do |z|
			    yy.flags.unshift z
		    end
                    if(x.flags[cin+1] == "@")
                        out.concat(yy)
                    else
                        out <<yy
                    end
                elsif LispString === x
                    out << x
                else
		    newdepth = depth 
		    newdepth += 1 if x.flags.first == "`" 
                    new_out = LispList.new(x.flags)
                    x.__compute_comma(new_out, lisp, local_vars, newdepth)
                    out << new_out
                end
            }
        end
        def compute(lisp, local_vars)
            if @flags.first == "'"
                out = LispList.new(@flags[1..-1])
                each { |x|    out << x }
                out
            elsif @flags.first == "`"
                out = LispList.new(@flags[1..-1])
                __compute_comma(out, lisp, local_vars)
                out
            elsif @flags.first.nil? || @flags.first == ","
                if lisp.__macros && macro = lisp.__macros[self[0]]
                    result = macro.call(self[1..-1] , local_vars)
                elsif lisp.respond_to?("#{self[0]}_")
                    result = lisp.send("#{self[0]}_", *(self[1..-1] + [local_vars]))
                else
                    name = self[0]
                    args = self[1..-1].collect { |x|
                        x.compute(lisp, local_vars)
                    }
                    result = lisp.send(self[0], *args)
                end    
                result
            else
                raise "What do I do with #{@flags.first}?"
            end        
        end
        #~ def inspect()
            #~ "#{flags.inspect}#{super}"
        #~ end                
    end
    
    Flags = %w{' ` , @}
    
    class LispString < String
        attr_reader :flags
        def initialize(string, flags)
            super(string)
            @flags = flags
        end
        def compute(lisp, local_vars)
            if(@flags.first == "'")
                LispString.new(self, @flags[1..-1])
            elsif @flags.first.nil? || @flags.first == ","
                if(self[0..1] == "#'")
                    lisp.method(self[2..-1])
                else
                    if local_vars.include?(self)
                        val = local_vars[self]
                    elsif lisp.__objects && lisp.__objects.include?(self)
                        val = lisp.__objects[self] 
                    else
                        raise "'#{self}' not defined" unless val
                    end unless val
                    val
                end        
            elsif @flags.first
                raise "What do I do with #{@flags.first}?"
            end
        end
        def to_lisp(flags=@flags)
            "#{flags}#{self}"
        end    
        #~ def inspect()
            #~ "#{flags.inspect}#{super}"
        #~ end        
    end
    #
    # Helper methods
    #
    def __macros
        @__lisp_macros ||= Hash.new
    end
    def __objects
        unless @__lisp_objects
            @__lisp_objects = Hash.new
            @__lisp_objects["t"] = true
            @__lisp_objects["nil"] = nil
        end
        @__lisp_objects
    end
    def parse_lisp(string, flags=[])
        string.gsub!("\n", " ")
        string.strip!
        args = LispList.new(flags)
        while string && !string.empty?
            newflags = []
            while(Flags.include?(string[0..0]))
                newflags << string[0..0]
                string = string[1..-1]
            end
            #~ string, newflags = LispFlags.parse(string, flags)
            index = string.index('(')
            if (index && index == 0)
                count = 1
                index += 1
                while count > 0
                    open = string.index('(', index)
                    close = string.index(')', index)
                    raise "Unmatched brackets" unless(close || open)
                    if(!open || close < open)
                        index = close+1
                        count -= 1
                    else
                        index = open+1
                        count += 1
                    end
                end
                current, string = string[1...(index-1)], string[index+1..-1]
                args << parse_lisp(current, newflags)
            else
                current, string = string.split(/\s+/, 2)
                args << LispString.new(current, newflags)
            end
            string.strip! if string
        end    
        args
    end
    def __convert(object)
        case object
            when LispList, LispString, Proc : object
            when Array
                out = LispList.new([])
                object.each {|x| out << __convert(x)}
                out
            when TrueClass
                LispString.new("t", [])
            when FalseClass, NilClass
                LispString.new("nil", [])
            when String
                LispString.new(object, [])
            else
                raise "What do i do with #{object.class}?"
        end
    end
    def lisp(string, local_vars=Hash.new)
        result = nil
        parsed = parse_lisp(string)
        parsed.each { |x|
            result = x.compute(self, local_vars)
        }
        __convert(result)
    end
    #
    # The core methods for lisp to work
    #
    def lambda_(args, block, local_vars, name=nil)
        Proc.new do |*procargs|
            if args.length == procargs.length
                new_local_vars = Hash.new
                new_local_vars.update(local_vars) if local_vars
                args.length.times do |i|
                    new_local_vars[args[i]] = procargs[i]
                end
                block.compute(self, new_local_vars)
            else
                raise ArgumentError, "wrong number of arguments (#{procargs.length} for #{args.length}) in #{name || block}"
            end        
        end        
    end
    def defun_(name, args, block, local_vars)
        @defun ||= Hash.new
        xx = lambda_(args, block, local_vars, name)
        self.class.module_eval do
            define_method name do |*args| xx.call(*args) end
        end
        name
    end
    def defmacro_(name, args, block, local_vars)
        if(args[-2] == "&rest")
            restarg = args[-1]
            args = args[0..-3]
        end
        __macros[name] = Proc.new do |procargs, proc_local_vars|
            new_local_vars = Hash.new
            new_local_vars.update(local_vars) if local_vars
            new_local_vars.update(proc_local_vars) if proc_local_vars
            args.length.times do |i|
                new_local_vars[args[i]] = procargs[i]
            end
            if(procargs.length > args.length)
                if(restarg)
                    list = LispList.new([])
                    procargs[args.length..-1].each { |x| list << x }
                    new_local_vars[restarg] = list
                else
                    raise ArgumentError, "wrong number of arguments (#{procargs.length} for #{args.length}) in #{name || block}"
                end
            end
            result = block.compute(self, new_local_vars)
            result = __convert(result)
            lisp(result.to_lisp, new_local_vars)
        end
        name
    end
    def setf_(key, value, local_vars)
        value = value.compute(self, local_vars)
        __objects[key] = value
        key
    end
    alias :defparameter_ :setf_
    def let_(assignment, block, local_vars)
        new_local_vars = Hash.new
        new_local_vars.update(local_vars) if local_vars
        value = assignment[0][1].compute(self, new_local_vars)
        new_local_vars[assignment[0][0]] = value
        block.compute(self, new_local_vars)
    end
    def cond_(*args)
        local_vars = args[-1]
        blocks = args[0..-2]
        blocks.each { |block|
            if(block[0].compute(self, local_vars))
                result = nil
                block[1..-1].each { |x|
                    result = x.compute(self, local_vars) 
                }
                return result
            end
        }
        p "Nothing!"
    end
end





o = Object.new
o.extend(Lisp)
o.extend(Lisp::StandardFunctions)

#~ xx = o.parse_lisp("`(',',string)")
#~ p xx[0]
#~ p xx[0].compute(o, {"string" => "chain"})
#~ exit







if $0 == __FILE__
    require 'test/unit'
    class TestLisp < Test::Unit::TestCase
        def setup
            @o = Object.new
            @o.extend(Lisp)
            @o.extend(Lisp::StandardFunctions)
        end
        def test_simple_array
            assert_equal(["x"], @o.lisp("'(x)"))
        end
        def test_simple_array2
            assert_equal(["x", "y","z"], @o.lisp("'(x y z)"))
        end
        def test_command_array
            @o.lisp("(setf *objects* '(whiskey-bottle bucket frog chain))")
            assert_equal(%w{whiskey-bottle bucket frog chain}, @o.__objects["*objects*"])
        end        
        def test_parse_reconstruct
            input = <<-EOF
(defspel game-action (command subj obj place &rest rest)
  `(defspel ,command (subject object)
     `(cond ((and (eq *location* ',',place)
          (eq ',subject ',',subj)
          (eq ',object ',',obj)
          (have ',',subj))
         ,@',rest)
        (t '(i cant ,',command like that.)))))    
            EOF
            input.gsub!(/[ \n]+/, " ")
            output = @o.parse_lisp(input)[0]
            puts
            #output.each {|x| x.each { |y| puts y.to_lisp } if Array === x}
            puts
            assert_equal(input, output.to_lisp)
        end
        def test_defun
            @o.lisp(<<-EOF)
(defun describe-location (location map)
  (second (assoc location map)))        
            EOF
            @o.lisp(<<-EOF)
(setf *map* '((living-room (you are in the living-room of a wizard's house. there is a wizard snoring loudly on the couch.)
               (west door garden)  
               (upstairs stairway attic))
          (garden (you are in a beautiful garden. there is a well in front of you.)
              (east door living-room))
          (attic (you are in the attic of the wizards house. there is a giant welding torch in the corner.)
             (downstairs stairway living-room))))
            EOF
            result = @o.lisp(<<-EOF)
(describe-location 'living-room *map*)
            EOF
            assert_equal(%w{you are in the living-room of a wizard's house. there is a wizard snoring loudly on the couch.}, result)
        end
        def test_lisp_game
            @o.lisp(<<-EOF)
(setf *objects* '(whiskey-bottle bucket chain frog))
            EOF
            @o.lisp(<<-EOF)
(setf *map* '((living-room (you are in the living-room of a wizard's house. there is a wizard snoring loudly on the couch.)
               (west door garden)  
               (upstairs stairway attic))
          (garden (you are in a beautiful garden. there is a well in front of you.)
              (east door living-room))
          (attic (you are in the attic of the wizards house. there is a giant welding torch in the corner.)
             (downstairs stairway living-room))))
(setf *object-locations* '((whiskey-bottle living-room)
               (bucket living-room)
               (chain garden)
               (frog garden)))        
(setf *location* 'living-room)        
            EOF
            result = @o.lisp(<<-EOF)
(defun describe-location (location map)
  (second (assoc location map)))        
(describe-location 'living-room *map*)
            EOF
            assert_equal(%w{you are in the living-room of a wizard's house. there is a wizard snoring loudly on the couch.}, result)
            result = @o.lisp(<<-EOF)
(defun describe-path (path)
  `(there is a ,(second path) going ,(first path) from here.))
(describe-path '(west door garden))  
            EOF
            assert_equal(%w{there is a door going west from here.}, result)
            result = @o.lisp(<<-EOF)
(defun describe-paths (location map)
  (apply #'append (mapcar #'describe-path (cddr (assoc location map)))))
(describe-paths 'living-room *map*)  
            EOF
            assert_equal(%w{there is a door going west from here. there is a stairway going upstairs from here.}, result)
            result = @o.lisp(<<-EOF)
(defun is-at (obj loc obj-loc)
  (eq (second (assoc obj obj-loc)) loc))
(is-at 'whiskey-bottle 'living-room *object-locations*)  
            EOF
            #assert_equal("t", result)
            result = @o.lisp(<<-EOF)
(defun describe-floor (loc objs obj-loc)
  (apply #'append (mapcar (lambda (x)
                `(you see a ,x on the floor.))
              (remove-if-not (lambda (x)
                       (is-at x loc obj-loc))
                     objs))))
(describe-floor 'living-room *objects* *object-locations*)
            EOF
            assert_equal(%w{you see a whiskey-bottle on the floor. you see a bucket on the floor.}, result)        
            result = @o.lisp(<<-EOF)
(defun look ()
  (append (describe-location *location* *map*)
      (describe-paths *location* *map*)
      (describe-floor *location* *objects* *object-locations*)))
(look)
            EOF
            assert_equal(%w{you are in the living-room of a wizard's house. 
    there is a wizard snoring loudly on the couch. 
    there is a door going west from here. 
    there is a stairway going upstairs from here. 
    you see a whiskey-bottle on the floor. 
    you see a bucket on the floor.}, result)        
            result = @o.lisp(<<-EOF)
(defun walk-direction (direction)
  (let ((next (assoc direction (cddr (assoc *location* *map*)))))
    (cond (next (setf *location* (third next)) (look))
      (t '(you cant go that way.)))))
(walk-direction 'west)
            EOF
            assert_equal(%w{you are in a beautiful garden. 
    there is a well in front of you. 
    there is a door going east from here. 
    you see a chain on the floor. 
    you see a frog on the floor.}, result)
            result = @o.lisp(<<-EOF)
(defmacro defspel (&rest rest) `(defmacro ,@rest))        
(defspel walk (direction)
  `(walk-direction ',direction))        
(walk east)
            EOF
            assert_equal(%w{you are in the living-room of a wizard's house.
    there is a wizard snoring loudly on the couch.
    there is a door going west from here.
    there is a stairway going upstairs from here.
    you see a whiskey-bottle on the floor.
    you see a bucket on the floor.}, result)
            result = @o.lisp(<<-EOF)
(defun pickup-object (object)
  (cond ((is-at object *location* *object-locations*) (push (list object 'body) *object-locations*)
                              `(you are now carrying the ,object))
    (t '(you cannot get that.))))
(defspel pickup (object)
  `(pickup-object ',object))    
(pickup whiskey-bottle)
            EOF
            assert_equal(%w{you are now carrying the whiskey-bottle}, result)
            result = @o.lisp(<<-EOF)
    (defun inventory ()
      (remove-if-not (lambda (x)
               (is-at x 'body *object-locations*))
             *objects*))
    (defun have (object)
      (member object (inventory)))
    (setf *chain-welded* nil)
    
    (defun weld (subject object)
      (cond ((and (eq *location* 'attic)
              (eq subject 'chain)
              (eq object 'bucket)
              (have 'chain)
              (have 'bucket)
              (not *chain-welded*))
         (setf *chain-welded* 't)
         '(the chain is now securely welded to the bucket.))
        (t '(you cannot weld like that.))))  
    (weld 'chain 'bucket)    
            EOF
            assert_equal(%w{you cannot weld like that.}, result)        
            result = @o.lisp(<<-EOF)
    (setf *bucket-filled* nil)
    
    (defun dunk (subject object)
      (cond ((and (eq *location* 'garden)
              (eq subject 'bucket)
              (eq object 'well)
              (have 'bucket)
              *chain-welded*)
         (setf *bucket-filled* 't) '(the bucket is now full of water))
        (t '(you cannot dunk like that.))))
    (defspel game-action (command subj obj place &rest rest)
      `(defspel ,command (subject object)
         `(cond ((and (eq *location* ',',place)
              (eq ',subject ',',subj)
              (eq ',object ',',obj)
              (have ',',subj))
             ,@',rest)
            (t '(i cant ,',command like that.)))))
    
    (game-action weld chain bucket attic
             (cond ((and (have 'bucket) (setf *chain-welded* 't)) '(the chain is now securely welded to the bucket.))
               (t '(you do not have a bucket.))))
    
    (game-action dunk bucket well garden
             (cond (*chain-welded* (setf *bucket-filled* 't) '(the bucket is now full of water))
               (t '(the water level is too low to reach.))))
    
    (game-action splash bucket wizard living-room
             (cond ((not *bucket-filled*) '(the bucket has nothing in it.))
               ((have 'frog) '(the wizard awakens and sees that you stole his frog. he is so upset he banishes you to the netherworlds- you lose! the end.))
               (t '(the wizard awakens from his slumber and greets you warmly. he hands you the magic low-carb donut- you win! the end.))))
    
    (weld chain bucket)           
            EOF
            assert_equal(%w{i cant weld like that.}, result)        
        end    
    end    
end