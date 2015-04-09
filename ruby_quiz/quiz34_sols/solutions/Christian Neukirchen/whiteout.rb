unless caller.empty?
  eval File.read($0).           # or extract from caller...
       gsub(/\A.*\0/m, '').
       tr(" \n\t\v", "0123").
       scan(/\d{4}/m).map { |s| s.to_i(4) }.
       pack("c*")
else
  require 'fileutils'
  ARGV.each { |file|
    code = File.read file
    FileUtils.copy file, file + ".dirty"
    File.open(file, "w") { |out|
      code.gsub!(/\A#!.*/) { |shebang|
        out.puts shebang
        ''
      }
      out.puts 'require "whiteout"'
      out.print "\0"
      code.each_byte { |b|
        out.print b.to_s(4).rjust(4).tr("0123", " \n\t\v")
      }
    }
  }
end
