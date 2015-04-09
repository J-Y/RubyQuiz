#! /usr/bin/ruby

# defaults
base = 16
min = 3
wl_file = "/usr/share/dict/words"
capitals = false

require 'optparse'

opts = OptionParser.new
opts.on(
  "-b=integer",
  "--base=integer",
  "number base, must be between 10 and 36, default is 16",
  Integer
)  {|val| base = val.to_i}

opts.on(
  "-w=filename",
  "--word-list=filename",
  "filename of word list file, default is /usr/share/dict/words",
  String
)  {|val| wl_file = val}
opts.on("--min=integer", "minimum length word to be considered,
default is 3", Integer)  {|val| min = val}
opts.on(
  "-C",
  "--allow-capitals",
  "words containing capital letters are normally not considered, this option overrides that"
)  {|val| capitals = true}

rest = opts.parse(*ARGV)

errors = []
errors << "Unknown option#{rest.size > 1 ? "s" : ""} #{rest.join(',')}" unless rest.empty?
errors << "Base must be between 10, and 36" unless (10..36).include?(base)
errors << "Minimum value of #{min} is unacceptable" unless min >= 1
min = min.to_i
errors << "Word list #{wl_file} not found" unless File.exist?(wl_file)

if errors.empty?
  # The real work gets done here.
  # For any given base, where 10 <= base <= 36, there will be 11-base letter 'digits'
  # starting with 'a'
  pat = capitals ? /^[#{"a-#{'abcdefghijklmnopqrstuvwxyz'[(base-11)].chr}"}]{#{min},}$/oi :
                   /^[#{"a-#{'abcdefghijklmnopqrstuvwxyz'[(base-11)].chr}"}]{#{min},}$/o
  File.open(wl_file) do |f|
    f.each do |word|
      puts word if word =~ pat
    end
  end
else
  print errors
  puts
  puts opts.to_s
end
