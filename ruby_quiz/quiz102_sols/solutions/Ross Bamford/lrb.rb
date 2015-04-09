#!/usr/bin/env ruby
#
# Literate ruby.
# for Ruby Quiz #102
require 'tempfile'

MAIN_BINDING = binding

module Lrb
  LRB_RX = /(?:^\s*>(.*?)$)    |
            (?:[^\\]\\begin\{code\}
                 (.*?)
               [^\\]\\end\{code\})/mxu

  class << self
    # Get individual blocks of code
    def lrb_blocks(str)
      str.scan(LRB_RX).map do |rb| 
        rb.compact.first.strip 
      end
    end
    
    # Get the whole code
    def lrb_code(str)
      lrb_blocks(str).join("\n") 
    end

    def lrb_dump(str, blk_idx = nil)
      get_lrb_code(str, blk_idx, false)
    end
        
    def lrb_exec(fn, args = [], blk_idx = nil, debug = $DEBUG)
      # Ruby will interpet the -d and set DEBUG in the new ruby
      # that replaces this process. However, to get output printed
      # now we need to check it manually.
      code = get_lrb_code(File.read(fn), blk_idx, debug)

      # Use a TempFile. We don't get the auto-delete stuff (finalizer
      # won't get run after we replace the process) but it's 
      # convenient for the auto naming, and we can delete it 
      # later, from the new interpreter.
      #
      # The added bonus is, if theres a parse error, the tempfile 
      # gets left behind which helps with debugging...
      tf = Tempfile.open(File.basename(fn), '.')
      tf << "at_exit { File.unlink(__FILE__) }\n"
      tf << code 
      tf.close(false) # finalizer will never run

      exec('ruby', *(args << tf.path))
    end

    def lrb_eval(code, blk_idx = nil, fn = nil, debug = $DEBUG)
      fn ||= '(lrb_eval)'
      eval(get_lrb_code(code, blk_idx, debug), MAIN_BINDING, 
           "#{fn} #{('(#' + blk_idx.to_s + ')') if blk_idx}")
    end

    def lrb_require(fn, blk_idx = nil, debug = $DEBUG)
      unless $".include?(fn)
        fn += '.lrb' if File.extname(fn).empty?

        unless File.exists?(fn + blk_idx.to_s)    # nil.to_s == "" so all good
          rfn = nil
          fn = $:.detect { |dir| File.exists?(rfn = File.join(dir,fn)) }
          fn = rfn if fn
        end

        if fn
          begin
            code = get_lrb_code(File.read(fn), blk_idx, debug)
          rescue
            raise LoadError, $!.message
          end
          
          eval(code, MAIN_BINDING, 
               "#{fn} #{('(#' + blk_idx.to_s + ')') if blk_idx}")
          $" << fn + blk_idx.to_s

          true
        else
          raise LoadError, "no such file to load - #{fn}"
        end 

      else
        false
      end
    end
    
    private
    
    def get_lrb_code(str, blk_idx = nil, debug = false)
      if blk_idx
        code=Lrb.lrb_blocks(str)[blk_idx] or raise "LRB: No block ##{blk_idx}"
      else
        code=Lrb.lrb_code(str) or raise "LRB: No code found"
      end

      if debug
        $stderr.puts " ************ LRB: Will execute ************** "
        $stderr.puts code
        $stderr.puts " ***************** LRB: END ****************** "
      end

      code
    end
  end
end

unless ($NO_CORE_LRB ||= false)  
  module Kernel
    private
    def lrb_exec(fn, args = [], blk_idx = nil, debug = $DEBUG)
      Lrb.lrb_exec(fn, args, blk_idx, debug)
    end
    
    def lrb_eval(code, blk_idx = nil, fn = nil, debug = $DEBUG)
      Lrb.lrb_eval(code, blk_idx, fn, debug)
    end

    def lrb_require(fn, blk_idx = nil, debug = $DEBUG)
      Lrb.lrb_require(fn, blk_idx, debug)
    end
  end
end

if $0 == __FILE__
  fn = ARGV.shift or raise ArgumentError,
              "LRB: lrb [--dump | filename [block#] [ruby / program opts...]]"
  
  if (poss_idx = ARGV.first).to_i.to_s == poss_idx
    blk_idx = ARGV.shift.to_i
  elsif poss_idx == '--'
    ARGV.shift
  end

  if File.extname(fn) == '.lrb'
    if ARGV.include?('--dump')
      puts Lrb.lrb_dump(File.read(fn), blk_idx)
    else
      lrb_exec(fn, ARGV, blk_idx, ARGV.include?('-d'))
    end
  else 
    exec('ruby', *(ARGV <<  fn))
  end
end
