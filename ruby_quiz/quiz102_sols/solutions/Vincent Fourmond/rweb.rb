#!/usr/bin/ruby 

module RWeb

  # Escapes a whole line if it starts with this regular expression: the
  # rest of the line is fed as is to the current output (text or code)
  # without interpretation.
  ESCAPE = /^\s*@@/

  # Inline code
  INLINE = /^\s*>+/

  # Beginning of a code block
  B_o_CODE = /^\s*\\begin\{code\}\s*$/

  # End of a code block
  E_o_CODE = /^\s*\\end\{code\}\s*$/

  # Takes an array of lines, and returns code lines and text lines
  # separately, optionnally including code in text
  def self.unliterate_lines(lines, include_code = false)
    text = []
    code = []
    current = text
    for line in lines
      case line
      when ESCAPE               # Escaping
        current << $'
      when INLINE
        code << $'
        text << $' if include_code
      when B_o_CODE
        if current == code
          current << line
        else
          current = code
        end
        text << line if include_code
      when E_o_CODE
        if current == text
          current << line
        else
          text << line if include_code
          current = text
        end
      else
        current << line
      end
    end
    return [code, text]
  end

  # Unliterates a file
  def self.unliterate_file(file, include_code = false)
    return unliterate_lines(File.open(file).readlines, include_code)
  end

  # Runs the unliterated code
  def self.run_code(code, bnd = TOPLEVEL_BINDING)
    eval(code.join, bnd)
  end

  # Runs a file.
  def self.run_file(file)
    run_code(unliterate_file(file).first)
  end

end

# Here, we hack our way through require so that we can include
# .lrb files and understand them as literate ruby.
module Kernel

  alias :old_kernel_require :require
  undef :require
  def require(file)
    # if file doesn't have an extension, we look for it
    # as a .lrb file.
    if file =~ /\.[^\/]*$/
      old_kernel_require(file)
    else
      found = false
      for path in ($:).map {|x| File.join(x, file + ".lrb") }
        if File.readable?(path)
          found = true
          RWeb::run_code(RWeb::unliterate_file(path).first, 
                         self.send(:binding))
          break
        end
      end
      old_kernel_require(file) unless found
    end
  end
end

# We remove the first element of ARGV so that the script believes
# it is called on its own
file = ARGV.shift
$0 = file
RWeb::run_file(file)
