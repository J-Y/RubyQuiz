puts File.readlines('/usr/share/dict/words').grep(/\A[a-#{((b=ARGV[0].to_i)-1).to_s(b)}]+\Z/)
