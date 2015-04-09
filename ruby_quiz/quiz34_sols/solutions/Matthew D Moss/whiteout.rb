#!/usr/bin/env ruby

Bits  = '01'
Blank = " \t"

def shebang(f)
    f.pos = 0 unless f.gets =~ /^#!/
end

def confuse(fname)
    File.open(fname, File::RDWR) do |f|
        shebang f
        f.pos, data = f.pos, f.read
        f.puts "require '#{File.basename($0, '.*')}'"
        f.write data.unpack('b*').join.tr(Bits, Blank)
    end
end

def clarify(fname)
    File.open(fname, File::RDONLY) do |f|
        shebang f
        f.gets # skip require 'whiteout'
        eval [f.read.tr(Blank, Bits)].pack('b*')
    end
end

if __FILE__ == $0
    ARGV.each { |fname| confuse fname }
else
    clarify($0)
end
