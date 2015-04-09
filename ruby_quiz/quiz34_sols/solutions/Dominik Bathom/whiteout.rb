require "zlib"

def encode_to_ws(str)
    str=Zlib::Deflate.deflate(str, 9)
    res=""
    str.each_byte { |b| res << b.to_s(3).rjust(6,"0") }
    res.tr("012", " \t\n")
end

def decode_from_ws(str)
    raise "wrong length" unless str.length%6 == 0
    str.tr!(" \t\n", "012")
    res=""
    for i in 0...(str.length/6)
        res << str[i*6, 6].to_i(3).chr
    end
    Zlib::Inflate.inflate(res)
end

if $0 == __FILE__
    if File.file?(f=ARGV[0])
        str=IO.read(f)
        File.open(f, "wb") { |out|
            if str =~ /\A#!.*/
                out.puts $&
            end
            out.puts 'require "whiteout"'
            out.print encode_to_ws(str)
        }
    else
        puts "usage #$0 file.rb"
    end
else
    if File.file?($0)
        str=File.read($0)
        str.sub!(/\A(#!.*)?require "whiteout".*?\n/m, "")
        eval('$0=__FILE__')
        eval(decode_from_ws(str))
    else
        raise "required whiteout from non-file"
    end
end
